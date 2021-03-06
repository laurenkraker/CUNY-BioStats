#1####

snail <- read.csv("https://raw.githubusercontent.com/jsgosnell/CUNY-BioStats/master/datasets/snail_modified_for_class.csv")
head(snail)
snail$Treatment <- as.factor(snail$Treatment)
require(plyr)
snail$Treatment_new <- revalue(snail$Treatment, c("1" = "Control", "2" = "Single predator",
                                                  "3" = "Two predators"))

require(lme4)
snail_mm <- lmer(FL ~ Treatment_new + (1|Container), snail)
summary(snail_mm)
plot(snail_mm)
check_mixed_model <- function (model, model_name = NULL) {
  #collection of things you might check for mixed model
  par(mfrow = c(2,3))
  #not sure what this does with mutliple random effects, so stop with 1 for now
  if(length(names(ranef(model))<2)){
    qqnorm(ranef(model, drop = T)[[1]], pch = 19, las = 1, cex = 1.4, main= paste(model_name, 
                                                                                  "\n Random effects Q-Q plot"))
  }
  plot(fitted(model),residuals(model), main = paste(model_name, 
                                                    "\n residuals vs fitted"))
  qqnorm(residuals(model), main =paste(model_name, 
                                       "\nresiduals q-q plot"))
  qqline(residuals(model))
  hist(residuals(model), main = paste(model_name, 
                                      "\nresidual histogram"))
}

check_mixed_model(snail_mm)


require(car)
Anova(snail_mm, type = "III")

require(multcomp)
snail_comparison <- glht(snail_mm, linfct = mcp(Treatment_new = "Tukey"))
summary(snail_comparison)

#graph using Rmisc
library(Rmisc)
library(ggplot2)
graph_output <- summarySE(snail, measurevar = "FL", groupvars = "Treatment_new")
bar_graph_with_error_bars <- ggplot(graph_output, 
                                     aes_string(x="Treatment_new", 
                                                y = "FL")) +
  geom_col() + 
  geom_errorbar(aes(ymin = FL - ci, 
                    ymax = FL + ci))+
  xlab("Treatment")+
  theme(axis.title.x = element_text(face="bold", size=28), 
        axis.title.y = element_text(face="bold", size=28), 
        axis.text.y  = element_text(size=20),
        axis.text.x  = element_text(size=20), 
        legend.text =element_text(size=20),
        legend.title = element_text(size=20, face="bold"),
        plot.title = element_text(hjust = 0.5, face="bold", size=32))+
ylim(c(0, 30))

bar_graph_with_error_bars

#2####

rings <- read.table("http://www.statsci.org/data/general/challenger.txt", 
                    header = T)
#can do as poisson
rings_poisson <- glm(Damaged ~ Temp, rings, family = "poisson")
summary(rings_poisson)
#note dispersion is ok
require(car)
Anova(rings_poisson, type = "III")
#or binomial (preffered as we can add info (number damaged and not!))
rings_binomial <- glm(cbind(Damaged, 6 - Damaged) ~ Temp, rings, family = "binomial")
summary(rings_binomial)
#note dispersion is ok
Anova(rings_binomial, type = "III")
#compare to lm
rings_lm <- lm(Damaged ~ Temp, rings)
summary(rings_lm)
#note dispersion is ok
Anova(rings_lm, type = "III")

#3####
whelk <- read.csv("https://raw.githubusercontent.com/jsgosnell/CUNY-BioStats/master/datasets/whelk.csv")
head(whelk)
summary(whelk)
require(ggplot2)
whelk_plot <- ggplot(whelk, aes_string(x="Shell.Length", y = "Mass")) +
  geom_point(aes_string(colour = "Location")) + 
  theme(axis.title.x = element_text(face="bold", size=28), 
        axis.title.y = element_text(face="bold", size=28), 
        axis.text.y  = element_text(size=20),
        axis.text.x  = element_text(size=20), 
        legend.text =element_text(size=20),
        legend.title = element_text(size=20, face="bold"),
        plot.title = element_text(hjust = 0.5, face="bold", size=32))
whelk_plot
#power fit
whelk_lm <- lm(Mass ~ Shell.Length, whelk, na.action = na.omit)

whelk_power <- nls(Mass ~ b0 * Shell.Length^b1, whelk, 
                   start = list(b0 = 1, b1=3), na.action = na.omit)
whelk_exponential <- nls(Mass ~ exp(b0 + b1 * Shell.Length), whelk, 
                         start = list(b0 =1, b1=0), na.action = na.omit)
AICc(whelk_lm, whelk_power, whelk_exponential)

#plot
whelk_plot + geom_smooth(method = "lm", se = FALSE, size = 1.5, color = "orange")+ 
  geom_smooth(method="nls", 
              # look at whelk_power$call
              formula = y ~ b0 * x^b1, 
              method.args = list(start = list(b0 = 1, 
                                              b1 = 3)), 
              se=FALSE, size = 1.5, color = "blue") +
  geom_smooth(method="nls", 
              # look at whelk_exponential$call
              formula = y ~ exp(b0 + b1 * x), 
              method.args = list(start = list(b0 = 1, 
                                              b1 = 0)), 
              se=FALSE, size = 1.5, color = "green")


#4####

require(mgcv)
require(MuMIn) #for AICc
team <- read.csv("https://raw.githubusercontent.com/jsgosnell/CUNY-BioStats/master/datasets/team_data_no_spaces.csv")
elevation_linear <- gam(PlotCarbon.tonnes ~ Elevation, data = team)
elevation_gam <- gam(PlotCarbon.tonnes ~ s(Elevation), data = team)
elevation_gamm <- gamm(PlotCarbon.tonnes ~s(Elevation), random = list(Site.Name = ~ 1), data = team)
AICc(elevation_gam, elevation_gamm, elevation_linear)

#5####
require(rpart)
head(kyphosis)
kyphosis_tree_information <- rpart(Kyphosis ~ ., data = kyphosis, 
                                   parms = list(split = 'information'))
plot(kyphosis_tree_information)
text(kyphosis_tree_information)

kyphosis_tree_gini <- rpart(Kyphosis ~ ., data = kyphosis)
plot(kyphosis_tree_gini)
text(kyphosis_tree_gini)
