library(gsheet)
library(tidyverse)
library(readxl)

### Meta-analysis of 3 cohorts: CRC and appendectomy (Y/N)
t2 <- read_xlsx("CRC-appendectomy meta-analysis.xlsx") %>% 
  arrange(fct_inorder(subsite), fct_inorder(group), fct_inorder(cohort)) %>% 
  mutate(std.err = ((ci.upper-ci.lower)/2)/qnorm(0.975))

# Layout sheet used to calculate spacings, row positions and subset df
ly <- read_xlsx("layout_appendix.xlsx", sheet = 3)
rowvec <- c(-0.5,4.5,10.5, 17.5,22.5,28.5, 35.5,40.5,46.5, 53.5,58.5,64.5, 71.5,76.5,82.5)
df <- data.frame(t2[, c(1,9)])

# Perform meta-analyses on groups with nest
library(metafor)
mas <- t2 %>% group_by(subsite, group) %>% nest() %>% 
  mutate(mods = lapply(data, function(df) rma(hr, sei = std.err, data=df, method="REML")))
ll1 <- mas$mods

# Extract data for table
results <- lapply(ll1, "[", c("b", "ci.lb", "ci.ub", "I2", "QEp"))
append.yn1 <- do.call(rbind, results) %>% as_tibble

# Complex plot with spacings

par(mar=c(5,4,1,2), mgp = c(2,0.5,0))
# Set position of rownames with li
li <- c(-1.3, -1.9)
cex1 <- 0.8
forest(t2$hr, ci.lb = t2$ci.lower, ci.ub = t2$ci.upper, xlab = "Hazard ratio", pch = 18, 
       rows = na.omit(ly$row.lev3), ylim = c(0, 90), alim = c(0, 2), 
       efac = 0.3, #annosym = c(" (", ", ", ")"),
       psize = 1.5, header = c("Subsite", "HR (95% CI)"), xlim = c(-3, 3.5),
       ilab = df, cex = cex1, 
       slab = t2$subsite1,
       ilab.pos = 4, ilab.xpos = li, refline = 1)

# Add meta-analyses and text in a loop
for(ind in 1:15) addpoly(ll1[[ind]], rev(rowvec)[ind], efac = 0.8, mlab = NA, 
                         #annosym = c(" (", ", ", ")"), 
                         cex = cex1, col = "grey")
text(li, 89, c("Cohort", "Group"), pos = 4, cex = cex1)
#text(-3, 31, "colon", pos = 4, cex = cex1)
#text(-3, 49, "colon", pos = 4, cex = cex1)


# Positions of p-het and I2 are 22 and 25
I2s <- round(unlist(sapply(ll1, "[", 25)), 1)
phets <- round(unlist(sapply(ll1, "[", 22)), 2)
#plabs <- function(x, y) as.expression(bquote("RE model"~I^2 * "=" ~ .(x)* "%" * ", p ="~ .(y) ))
plabs <- function(x, y) as.expression(bquote(I^2 * "=" ~ .(x)* "%" * ", P ="~ .(y) ))

# Function name comes first in mapply (opposite to sapply)
text(li[1], rev(rowvec), labels = mapply(plabs, I2s, phets), cex = cex1, pos = 4)

# Save at 15 x 7 inch landscape

# Basic plot, no spacing (not used)
par(mar=c(5,4,1,2))
forest(t2$hr, ci.lb = t2$ci.lower, ci.ub = t2$ci.upper, xlab = "Hazard ratio", pch = 18, 
       psize = 1.5, slab = t2$subsite, ilab = df, header = T, xlim = c(-3, 5),
       ilab.pos = 4, ilab.xpos = c(-0.8, -1.8), refline = 1)


### CRC and age at appendectomy (reference no appendectomy)

t4 <- read_xlsx("CRC-appendectomy meta-analysis.xlsx", sheet = 3) %>% 
  arrange(fct_inorder(subsite), fct_inorder(group), fct_inorder(cohort)) %>% 
  mutate(std.err = ((ci.upper-ci.lower)/2)/qnorm(0.975))

rowvec <- c(-0.5,5.5,12.5, 18.5,25.5,31.5, 38.5,44.5,51.5, 57.5)
ly2 <- read_xlsx("layout_appendix.xlsx", sheet = 6)

df <- data.frame(t4[, c(1,10)])

# Perform meta-analyses (only 13 due to non-estimable men in EPIC)
mas <- t4 %>% group_by(subsite, group) %>% nest() %>% 
  mutate(mods = lapply(data, function(df) rma(hr, sei = std.err, data=df, method="REML")))
ll2 <- mas$mods

# Extract data for table
library(metafor)
results2 <- lapply(ll2, "[", c("b", "ci.lb", "ci.ub", "I2", "QEp"))
age.append.yn1 <- do.call(rbind, results2) %>% as_tibble

# Save at 11 x 7 in

# Simple plot
#forest(t4$hr, ci.lb = t4$ci.lower, ci.ub = t4$ci.upper, pch = 18, psize = 1.5, slab = t4$subsite1, 
#       header = T, xlim = c(-3, 5), ilab.pos = 4, ilab.xpos = c(-0.8, -1.8), refline = 1)

# Complex plot with spacings
par(mar=c(5,4,1,2), mgp = c(2,0.5,0))
li <- c(-1.2, -2.5)
cex1 <- 0.8
forest(t4$hr, ci.lb = t4$ci.lower, ci.ub = t4$ci.upper, xlab = "Hazard ratio", pch = 18, 
       rows = na.omit(ly2$row.lev3), ylim = c(0, 64), efac = 0.5, psize = 1.5, 
       header = c("Subsite", "HR (95% CI)"), xlim = c(-4, 4), ilab = df, cex = cex1, 
       slab = t4$subsite1, ilab.pos = 4, ilab.xpos = li, refline = 1)

par("usr")

# Add meta-analyses and text in a loop
for(ind in 1:10) addpoly(ll2[[ind]], rev(rowvec)[ind], efac = 0.8, mlab = NA, cex = cex1, col = "grey")

I2s <- round(unlist(sapply(ll2, "[", 25)), 1)
phets <- round(unlist(sapply(ll2, "[", 22)), 2)
plabs <- function(x, y) as.expression(bquote(I^2 * "=" ~ .(x)* "%" * "," ~ italic(P) ~ "=" ~ .(y) ))
text(li[2], rev(rowvec), labels = mapply(plabs, I2s, phets), cex = cex1, pos = 4)

text(li, 63, c("Cohort", "Group"), pos = 4, cex = cex1)



# Old: age at appendectomy, reference <20 group

t3 <- read_xlsx("CRC-appendectomy meta-analysis.xlsx", sheet = 2) %>% 
  arrange(fct_inorder(subsite), fct_inorder(group), fct_inorder(cohort)) %>% 
  mutate(std.err = ((ci.upper-ci.lower)/2)/qnorm(0.975))

df <- data.frame(t3[, c(1,7)])

# Perform meta-analyses (only 13 due to non-estimable men in EPIC)
# Exclude ma6 for forest plot only
ma1 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 1:3)
ma2 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 4:6)
ma3 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 7:8)
ma4 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 9:11)
ma5 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 12:14)
ma6 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 15:16)
ma7 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 17:19)
ma8 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 20:22)
#ma9 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 23:24)
ma10 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 25:27)
ma11 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 28:30)
#ma12 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 31:32)
ma13 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 33:35)
ma14 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 36:38)
ma15 <- rma(hr, sei = std.err, data=t3, method="REML", subset = 39:40)

# Remove extreme point (row 16)
t3[16, c(4:6)] <- NA

# For results or forest plot
ll <- list(ma15,ma14,ma13,   ma11,ma10,  ma8,ma7,  ma6, ma5,ma4,ma3,ma2,ma1)
#ll <- list(ma15,ma14,ma13,   ma11,ma10,  ma8,ma7,  ma5,ma4,ma3,ma2,ma1)
rowvec <- c(-0.5,4.5,10.5,   21.5,27.5, 38.5,44.5,  55.5,61.5, 68.5,73.5,79.5)

# Extract data for table
results <- lapply(rev(ll), "[", c("b", "ci.lb", "ci.ub", "I2", "QEp"))
append.yn <- do.call(rbind, results) %>% as_tibble


# Or using nest
mas <- t3 %>% group_by(subsite, group) %>% nest() %>%
  mutate(mods = lapply(data, function(df) rma(hr, sei = std.err, data=df, method="REML")))


# Extract data for table
results3 <- lapply(mas$mods, "[", c("b", "ci.lb", "ci.ub", "I2", "QEp"))
age.append.yn1 <- do.call(rbind, results3) %>% as_tibble


# Complex plot with spacings
# Remove extreme point (row 16) and get extra columns
t3[16, c(4:6)] <- NA
df <- data.frame(t3[, c(1,9)])

# Main plot
par(mar=c(5,4,1,2), mgp = c(2,0.5,0))
li <- c(-1, -2.7)
forest(t3$hr, ci.lb = t3$ci.lower, ci.ub = t3$ci.upper, xlab = "Hazard ratio", pch = 18, 
       rows = na.omit(ly$row.lev3), ylim = c(0, 87), 
       alim = c(0, 4), 
       efac = 0.5,
       psize = 1.5, header = c("Subsite", "HR (95% CI)"), xlim = c(-4, 6),
       ilab = df, cex = 0.7, slab = t3$subsite1,
       ilab.pos = 4, ilab.xpos = li, refline = 1)

# Add meta-analyses and text in a loop
for(ind in 1:12) addpoly(ll[[ind]], rowvec[ind], efac = 0.8, mlab = NA, cex = 0.7, col = "grey")

I2s <- round(unlist(sapply(ll, "[", 25)), 1)
phets <- round(unlist(sapply(ll, "[", 22)), 2)
plabs <- function(x, y) as.expression(bquote("RE model"~I^2 * "=" ~ .(x)* "%" * "," ~ italic(P) ~ "="~ .(y) ))
text(li[2], rowvec, labels = mapply(plabs, I2s, phets), cex = 0.7, pos = 4)

text(li, 86, c("Cohort", "Group"), pos = 4, cex = 0.7)
