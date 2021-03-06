#Using 5% of 100000 people, I will consider the probability distribution 
#with the probability of being a doctor is 0.005.

a<-rbinom(10000,5000,0.0005 )
hist(a)
mean(a)
sd(a)
quantile(a,c(0.025,0.975))

#I will repeat this process with differnt probabilities from 0.0005 to 0.005.
prob46 <- rep(NA,46)
mean46 <- rep(NA,46)
sd46 <- rep(NA,46)
qlow46 <- rep(NA,46)
qhigh46 <- rep(NA,46)


for (i in 1:46){
        prob <- 0.0005+0.0001*(i-1)
        set.seed(1)
        a <- rbinom(10000,5000,prob)*20     #consider #doctors/100K people
        prob46[i] <- prob
        mean46[i] <- mean(a)
        sd46[i] <- sd(a)
        qlow46[i] <- quantile(a,0.025)
        qhigh46[i] <- quantile(a,0.975)
}

result <- data.frame(prob46,mean46,sd46,qlow46,qhigh46)


#I will compare the quantile above with the quantile calculated by std.
lower1.96 <- mean46 - sd46*1.96
higher1.96 <- mean46 + sd46*1.96
result <- data.frame(result, lower1.96, higher1.96)

#Function to return SE calculated using rep weights with N~(1,2.5)

SEcalc <- function(no_doc){
        repdoc <- rep(NA, 80)
  
        for (i in 1:80){
                set.seed(i)
                repdoc[i] <- sum(rnorm(no_doc,1,2.5))  
        }
  
        differencesq <- (repdoc - no_doc)^2
        SE <- sqrt(4/80 * sum(differencesq))
        rm(repdoc,differencesq)
        SE
}


#Get SEs for a different number of docs using the function above.
#Number of docs will range from 1 to 1500

doctors <- 1:1500
SEresult <- rep(NA,1500)

for (i in doctors){
        SEresult[i] <- SEcalc(i)
}

SEresult <- c(0,SEresult)

#Incorporate weights-based error into each trial of 10K draws

SEresult46 <- rep(NA,46)

for (i in 1:46){
        prob <- 0.0005+0.0001*(i-1)
        set.seed(1)
        a <- rbinom(10000,5000,prob)*20
  
        #If the #doc is 1, I want the value of the 2nd row of SEresult.
        b<- a+1                          
        c <- rep(NA,10000)
        c <- SEresult[b]
        SEresult46[i] <- mean(c)        #Mean of 10K SE
        rm(prob,a,b,c)
}


result2 <- data.frame(result,SEresult46)

replower1.96 <- result$mean46 - SEresult46*1.96
rephigher1.96 <- result$mean46 + SEresult46*1.96

result2 <- data.frame(result,replower1.96,rephigher1.96)
save(result2,file="result2.RData")

a <- result2$prob46
b <- result2$mean46
c <- result2$qlow46
d <- result2$qhigh46
e <- result2$lower1.96
f <- result2$higher1.96

plot(a, b,col="1",xlim=c(0.0005,0.005),type="l",lty=2,
     xlab="Probability of Being a Doctor",ylab="#Doctors per 100K People")
lines(a,c,col="1")
lines(a,d,col="1")
lines(a,e,col="2")
lines(a,f,col="2")
lines(a,rephigher1.96,col="4")
lines(a,replower1.96,col="4")

name <- c("Mean", "Actual (2.5%,97.5%)", "CI by 1.96*Standard Deviation",
          "CI by Weights(2.5)-Based Error")
legend(x="topleft",legend=c(name),col=c("1","1","2","4"),
       lty=c(2,1,1,1),cex=0.75,bty="n")