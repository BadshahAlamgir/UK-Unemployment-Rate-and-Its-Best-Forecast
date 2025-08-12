
library(tseries)
library(forecast)


library(readr)
unemp <- read_csv("C:/Users/Lenovo/Downloads/unemp.csv")

unemp_ts <- ts(data = unemp$`Unemployment Rate` , start = c(1985,1),frequency = 12 )
head(unemp_ts)
plot(unemp_ts , main = "Whole Time Series from 1985 to 2023", ylab = "Unemployment Rate" , xlab= "Year")

#Training and testing data

tra <- head(unemp_ts , n=419)
te <- tail(unemp_ts , n =48)

fs <- HoltWinters(unemp_ts , beta = F, gamma = F)
plot(forecast(fs , h=60),main = "Forecast from SES",xlab = "Time",ylab = "Unemployment Rate")
#simple exponential smoothing
ses <- function(x, alpha) {
  n <- length(x)
  s <- rep(NA, n)
  s[1] <- x[1]
  for (i in 2:n) {
    s[i] <- alpha * x[i] + (1 - alpha) * s[i - 1]
  }
  return(s)
}

# Perform SES
alpha <- 0.2  # Smoothing parameter (0 < alpha < 1)
mses <- ses(tra, alpha)

fses <- rep(mses[length(mses)], 60)
fses<- as.tibble(fses)
fses$`Point Forecast`


fff <- forecast(ses(unemp_ts , alpha),h=60)

fff <- as.tibble(fff)
fff <- ts(fff , start = c(1985,1), frequency = 12)
plot(fff ,  main = "Forecast from SES",xlab = "Time",ylab = "Unemployment Rate")
#sse of ses model
sseses <- sum((fses$`Point Forecast`-te)^2)

#Holt's linear smoothing

mholt <- HoltWinters(tra)
fholt <- forecast(mholt , h = 48)
plot(forecast(HoltWinters(unemp_ts), h=60 ), ylim= c(0 ,15), xlab = "Time", ylab = "Unemployment Rate")
#SSE of Holt's method
sse <- sum((fholt$mean - test_tss)^2)
sse

#ARIMA model
marima <- Arima(tra , order = c(0 , 1 , 1))
farima <- forecast(marima , h = 48)
plot(farima ,  xlab = "Time", ylab = "Unemployment Rate")
#SSE of ARIMA model
ssear <- sum((farima$mean - test_tss)^2)
ssear

#Regression Model
ndat <- data.frame(tim = (length(unemp_ts)+1):(length(unemp_ts)+60))
da <- data.frame(unemp_ts, tim = 1:length(tra))

new_data <- data.frame(Time = seq(468,527))

mreg <- lm(unemp_ts ~seq(1,467) )
freg <- forecast(mreg ,newdata = new_data)
plot(freg)




#SSE of regression model
ssereg <- sum((freg- te)^2)
ssereg

#SSE table for all the model
ss<- data.frame(Model = c("SES","Holt","Arima","Regression"), SSE=c(sseses,sse,ssear,ssereg) )
as_tibble(ss)
