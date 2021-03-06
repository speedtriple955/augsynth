context("Generally testing the workflow for augsynth")


library(Synth)
data(basque)
basque <- basque %>% mutate(trt = case_when(year < 1975 ~ 0,
                                            regionno != 17 ~0,
                                            regionno == 17 ~ 1)) %>%
    filter(regionno != 1)


                            
test_that("SCM gives the right answer", {

    syn <- augsynth(gdpcap ~ trt, regionno, year, basque, progfunc="None", scm=T, t_int=1975)
    ## average att estimate is as expected
    expect_equal(-.3686, mean(summary(syn)$att$Estimate), tolerance=1e-4)

    ## average se estimate is as expected
    expect_equal(0.079,
                 mean(summary(syn)$att$Std.Error, na.rm = T),
                 tolerance=1e-3)

    ## level of balance is as expected
    expect_equal(.377, syn$l2_imbalance, tolerance=1e-3)

}
)

test_that("SCM finds the correct t_int and gives the right answer", {

    syn1 <- augsynth(gdpcap ~ trt, regionno, year, basque,
                     progfunc="None", scm=T)
    syn2 <- augsynth(gdpcap ~ trt, regionno, year, basque,
                     progfunc = "None", scm = T, t_int = 1975)
    ## average att estimate is as expected
    expect_equal(mean(summary(syn1)$att$Estimate), 
                 mean(summary(syn2)$att$Estimate), tolerance=1e-4)
    
    ## average se estimate is as expected
    expect_equal(mean(summary(syn1)$att$Std.Error, na.rm=T),
                 mean(summary(syn2)$att$Std.Error, na.rm=T),
                 tolerance=1e-3)
    
    ## level of balance is as expected
    expect_equal(syn1$l2_imbalance, syn2$l2_imbalance, tolerance=1e-3)
    
}
)


test_that("Ridge ASCM gives the right answer", {

    asyn <- augsynth(gdpcap ~ trt, regionno, year, basque, progfunc="Ridge",
                     scm=T, lambda=8)

    ## average att estimate is as expected
    expect_equal(-.3696, mean(summary(asyn)$att$Estimate), tolerance=1e-3)

    ## average se estimate is as expected
    expect_equal(0.1558,
                 mean(summary(asyn)$att$Std.Error, na.rm=T),
                 tolerance=1e-3)

    ## level of balance is as expected
    expect_equal(.373, asyn$l2_imbalance, tolerance=1e-3)

}
)




test_that("Ridge ASCM with covariates gives the right answer", {

    covsyn <- augsynth(gdpcap ~ trt | invest + popdens,
                       regionno, year, basque,
                       progfunc="None", scm=T, t_int = 1975)

    ## average att estimate is as expected
    expect_equal(-.1443,
                 mean(summary(covsyn)$att$Estimate),
                 tolerance = 1e-3)

    ## average se estimate is as expected
    expect_equal(0.4518,
                 mean(summary(covsyn)$att$Std.Error, na.rm = T),
                 tolerance=1e-3)

    ## level of balance is as expected
    expect_equal(.3720, covsyn$l2_imbalance, tolerance=1e-3)

}
)

test_that("Test interaction between all types of prog_func and optional parameters", {
    expect_warning(augsynth(gdpcap ~ trt| invest + popdens, regionno, year, basque, progfunc="EN", scm=T, lambda=8, t_int = 1975, bad_param = "Unused input parameter"))
    expect_warning(augsynth(gdpcap ~ trt| invest + popdens, regionno, year, basque, progfunc="RF", scm=T, lambda=8, t_int = 1975, bad_param = "Unused input parameter"))
})
