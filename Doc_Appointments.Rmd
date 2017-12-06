# Logistics Regression Analysis: Medical Appointments

Prediction: No Show Appointments

Date: '`r format(Sys.Date(), "%B %d, %Y")`'

Participants: Sarah Fite, Matthew Przybyla, and David Tran

```{r include=FALSE}
library(caTools)
library(ggplot2)
library(glmnet)
library(ROCR)
library(nnet)
library(aod)
Data = read.csv(file="C:/Users/zdtra/OneDrive/Desktop/School/SMU/Classes/AUG2017/MSDS 6372 - Applied Statistics - Inference and Modeling/Project 3/KaggleV2-May-2016.csv", header=TRUE, sep=",")
Data_Sub <- subset(Data, select=c(3,6,8,9,10,11,12,13,14))
```

# Summary and Statistics 
```{r}
head(Data_Sub)
str(Data_Sub)
sapply(Data_Sub, sd)
xtabs(~NOSHOW + Gender, data = Data_Sub)
```

# Fitting the Model 
```{r}
model <- glm(NOSHOW ~., family=binomial(link='logit'), data=Data_Sub)
predict <- predict(model, type ='response')

summary(model)
anova(model, test="Chisq")
confint(model)
```

# Misclassification Rate 
```{r}
p <- predict(model, Data_Sub)
table <- table(p, Data_Sub$NOSHOW)
Classification_Rate = sum(diag(table))/sum(table)
Classification_Rate
Misclassification_Rate = 1- sum(diag(table))/sum(table)
Misclassification_Rate
```

#Model Performance Evaluation  
```{r}
pred <- predict(model, Data_Sub, type= "response")
head(pred)
head(Data_Sub)
hist(pred)
predf <- prediction(pred, Data_Sub$NOSHOW)
eval <- performance(predf, "acc")
plot(eval)
abline(h=0.80, v=0.35)
```

#Reciever Operating Characteristic (ROC) Curve & Area Under Curve (AUC)
```{r}
pred2 <- prediction(pred, Data_Sub$NOSHOW)
roc <- performance(pred2, "tpr", "fpr")
plot(roc,
     colorize=T,
     main = "ROC Curve",
     ylab = "Sensitivity",
     xlab = "1 - Specificity")
abline(a=0, b=1)
auc <- performance(pred2, "auc")
auc2 <- unlist(slot(auc, "y.values"))
auc3 <- round(auc2, 4)
legend(.6, .2, auc3, title = "AUC", cex =.5)
```

# Identify Best Values
```{r}
max <- which.max(slot(eval, "y.values")[[1]])
max
acc <- slot(eval, "y.values")[[1]][max]
acc
cut <- slot(eval, "x.values")[[1]][max]
cut
```
