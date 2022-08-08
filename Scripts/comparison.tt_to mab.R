tt.df <- read.csv("measure_output_0_1_3_rescale.csv", header = TRUE)
colnames(tt.df)
tt.df2 <- tt.df[, c(1:12)]
colnames(tt.df2)


mab.df <- read.csv("meta.merged.measure.burress.errors.removed.rescaled.csv", header = TRUE)
mab.df2 <- mab.df[, c(1,33:43)]
colnames(mab.df)

head(tt.df2$X)
head(mab.df2$original_file_name)

df.merge <- merge(tt.df2, mab.df2, by.x = "X", by.y = "original_file_name")
nrow(mab.df2)
nrow(tt.df2)
nrow(df.merge)

df.merge$SL_bbox.diff <- df.merge$SL_bbox - (df.merge$SL_bbox.conv/10)
df.merge$SL_lm.diff <- df.merge$SL_lm - (df.merge$SL_lm.conv/10)
df.merge$HL_bbox.diff <- df.merge$HL_bbox - (df.merge$HL_bbox.conv/10)
df.merge$HL_lm.diff <- df.merge$HL_lm - (df.merge$HL_lm.conv/10)
df.merge$pOD_bbox.diff <- df.merge$pOD_bbox - (df.merge$pOD_bbox.conv/10)
df.merge$pOD_lm.diff <- df.merge$pOD_lm - (df.merge$pOD_lm.conv/10)
df.merge$ED_bbox.diff <- df.merge$ED_bbox - (df.merge$ED_bbox.conv/10)
df.merge$ED_lm.diff <- df.merge$ED_lm - (df.merge$ED_lm.conv/10)
df.merge$HH_lm.diff <- df.merge$HH_lm - (df.merge$HH_lm.conv/10)
df.merge$EA_m.diff <- df.merge$EA_m - (df.merge$EA_m.conv/10)
df.merge$HA_m.diff <- df.merge$HA_m - (df.merge$HA_m.conv/10)

colnames(df.merge)

write.csv(df.merge, "mab.tt.rescale.csv", row.names = FALSE)

