## Created by Pablo Diego Rosell, PhD, for Gallup inc. in September 2018
# Test of Hypothesis 1.2 and all associated predictions

# Recode tools into specific test

factorial$h1.2[factorial$tools==1]<- 0
factorial$h1.2[factorial$tools==4]<- 1

# Recode competition variable

factorial$competition2[factorial$h1.1==0]<- 0
factorial$competition2[factorial$h1.1==1 | factorial$h1.1==2 |factorial$h1.1==3]<- 1

# Declare formula

formula.h1.2 <- innovation~competition2*h1.2+h1.3+h2.1+h3.1+h3.2+
  h3.3+h3.4+h3.5+(1|matchid)

# Identify location of relevant coefficients for main formula

coefficients <- stan_glmer(formula.h1.2, data=factorial, family = binomial(link = "logit"), 
                           chains = 1, iter = 100)
ndim.1.2 <- length(coefficients$prior.info$prior$location)
# set dimension placeholder

# Manually set priors for all h1.2. predictions
# Assume SD = half of a large effect

test.SD<-log.odds.large/2
test.SDinter<-(log.odds.large*log.odds.large)/2

# Null hypothesis: Competition levels and prospects have 0 effect on risk-seeking behavior 

h1.2.null <- cauchy(location = rep(0,ndim.1.2), 
                    scale = c(0.01,0.01,rep(2.5,ndim.1.2-3), 0.01), autoscale = FALSE)

# Test hypothesis: Groups will be more risk-seeking in a competitive environment than in a non-competitive environment.  

h1.2.test <- cauchy(location = c(0, log.odds.large, rep(0,ndim.1.2-3), log.odds.large), 
                    scale = c(test.SD,test.SD,rep(2.5,ndim.1.2-3), test.SDinter), autoscale = FALSE)

# Alt hypothesis 1: Groups will be equally risk-seeking, irrespective of competition levels. 

h1.2.alt1 <- cauchy(location = c(0, log.odds.large, rep(0,ndim.1.2-3), 0), 
                    scale = c(test.SD,test.SD,rep(2.5,ndim.1.2-3), test.SDinter), autoscale = FALSE)

# Alt hypothesis 2: Group motivation to innovate will increase linearly with the expected value of the innovation, irrespective of competition levels.

h1.2.alt2 <- cauchy(location = c(0, 0, rep(0,ndim.1.2-3), 0), 
                    scale = c(test.SD,test.SD,rep(2.5,ndim.1.2-3), test.SDinter), autoscale = FALSE)

# Estimate and save all models

glmm1.2.null<- bayesGlmer(formula.h1.2, h1.2.null)
glmm1.2.test<- bayesGlmer(formula.h1.2, h1.2.test)
glmm1.2.alt1<- bayesGlmer(formula.h1.2, h1.2.alt1)
glmm1.2.alt2<- bayesGlmer(formula.h1.2, h1.2.alt2)

# Estimate marginal likelihood

bridge_1.2.null <- bridge_sampler(glmm1.2.null)
bridge_1.2.test <- bridge_sampler(glmm1.2.test)
bridge_1.2.alt1 <- bridge_sampler(glmm1.2.alt1)
bridge_1.2.alt2 <- bridge_sampler(glmm1.2.alt2)

# Calculate BFs for all comparisons

testalt1.1.2<-bf(bridge_1.2.test, bridge_1.2.alt1)$bf
testalt2.1.2<-bf(bridge_1.2.test, bridge_1.2.alt2)$bf
alt1alt2.1.2<-bf(bridge_1.2.alt1, bridge_1.2.alt2)$bf
testnull.1.2<-bf(bridge_1.2.test, bridge_1.2.null)$bf
alt1null.1.2<-bf(bridge_1.2.alt1, bridge_1.2.null)$bf
alt2null.1.2<-bf(bridge_1.2.alt2, bridge_1.2.null)$bf