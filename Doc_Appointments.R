#Importing the Libraries 
library(caTools)
library(ggplot2)
library(glmnet)
library(ROCR)
library(nnet)
library(aod)

#Import the Data & Summaries 
Data = read.csv(file="C:/Users/zdtra/OneDrive/Desktop/School/SMU/Classes/AUG2017/MSDS 6372 - Applied Statistics - Inference and Modeling/Project 3/KaggleV2-May-2016.csv", header=TRUE, sep=",")
Data_Sub <- subset(Data, select=c(3,6,8,9,10,11,12,13,14))
head(Data_Sub)
str(Data_Sub)
sapply(Data_Sub, sd)

xtabs(~NOSHOW + Age, data = Data_Sub)

# Fitting the Model 
model <- multinom(NOSHOW ~., data=Data_Sub)
predict <- predict(model, type ='response')

plot(model)
train_idx <- sample(1:nrow(Data), 1000, replace=FALSE)
train <- Data[train_idx,]
test <- Data[-train_idx,]

#ggplot the data
ggplot(Data_Sub, aes(x=Age, y=NOSHOW)) + geom_point() + 
  stat_smooth(method="glm", family="binomial", se=FALSE)

ggplot(Data_Sub, aes(x = Age, y = NOSHOW)) + geom_ribbon(aes(ymin = LL,
    ymax = UL, fill = rank), alpha = 0.2) + geom_line(aes(colour = rank),
    size = 1)

#Confusion Matrix
p <- predict(model, Data_Sub)
table <- table(p, Data_Sub$NOSHOW)
table
sum(diag(table))/sum(table)
1- sum(diag(table))/sum(table)

table(Data_Sub$NOSHOW)
88208/(88208+22319)

#ROCR & Model Performance Evaluation 
pred <- predict(model, Data_Sub, type= 'prob')
head(Data_Sub)
predf <- prediction(pred, Data_Sub$NOSHOW)
eval <- performance(predf, "acc")
plot(eval)
abline(h=0.80, v=0.35)

#ROCR Curve
pred <- prediction(pred, Data_Sub$NOSHOW)
roc <- performance(pred, "tpr", "fpr")
plot(roc,
     colorize=T,
     main = "ROC Curve",
     ylab = "Sensitivity",
     xlab = "1 - Specificity")
abline(a=0, b=1)

# Area Under Curve (AUC)
auc <- performance(pred, "auc")
auc <- unlist(slot(auc, "y.values"))
auc <- round(auc, 4)
legend(.6, .2, auc, title = "AUC", cex =.5)

# Identify Best Values
max <- which.max(slot(eval, "y.values")[[1]])
acc <- slot(eval, "y.values")[[1]][max]
cut <- slot(eval, "x.values")[[1]][max]

#histogram
hist(pred)

# Summary, Confint, and ANOVA
summary(model)
confint(model)
anova.multinom(model, test="Chisq")
