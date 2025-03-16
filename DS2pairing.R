###
rm(list=ls())
### Wu, Yi-Hung @ ICE.CYCU 2025/3
### =======================================================
# Input CSV file
# setwd(choose.dir())
# df <- read.csv(choose.files(),header=F,fileEncoding="Big5")
df <- read.csv("DS2class.csv",header=F,fileEncoding="Big5")
df <- rbind(df, if (nrow(df) %% 2) setNames(as.list(rep("99999", ncol(df))), names(df)))
# View(df)
names(df) <- c("StudentID","Name")
data <- df

# 載入必要函式庫
library(dplyr)

# 設定 N，確保為偶數
# set.seed(321)  # 321, 123設定隨機種子，確保結果可重現
N <- nrow(data)  # 必須為偶數

# 第一次隨機分配整數欄位
data <- data %>%
  mutate(RandomOrder = sample(1:N, N)) %>%
  arrange(RandomOrder) %>%
  select(-RandomOrder)  # 排序後刪除該欄位
# View(data)

# 第二次隨機分配整數欄位
data <- data %>%
  mutate(RandomOrder = sample(1:N, N)) %>%
  arrange(RandomOrder) %>%
  select(-RandomOrder)  # 排序後刪除該欄位
# View(data)

# 第三次隨機分配整數欄位
data <- data %>%
  mutate(RandomOrder = sample(1:N, N)) %>%
  arrange(RandomOrder) %>%
  select(-RandomOrder)  # 排序後刪除該欄位
# View(data)

# 進行二人配對，形成 N/2 x 4 的 data frame
paired_data <- data.frame(
  Left_StudentID = numeric(N/2),
  Left_Name = character(N/2),
  Right_StudentID = numeric(N/2),
  Right_Name = character(N/2),
  stringsAsFactors = FALSE
)

for (i in seq(1, N, by = 2)) {
  pair <- data[i:(i+1), ]  # 取得相鄰兩筆資料
  
  # 根據學號大小決定左右位置
  if (pair$StudentID[1] < pair$StudentID[2]) {
    paired_data[(i+1)/2, ] <- c(pair$StudentID[1], pair$Name[1], pair$StudentID[2], pair$Name[2])
  } else {
    paired_data[(i+1)/2, ] <- c(pair$StudentID[2], pair$Name[2], pair$StudentID[1], pair$Name[1])
  }
}
# View(paired_data)

# 按照左邊的學號由小到大排序
paired_data <- paired_data %>%
  arrange(Left_StudentID)

# 新增組別編號
paired_data <- paired_data %>%
  mutate(Group = 1:(N/2)) %>%
  select(Group, everything())  # 調整欄位順序
# View(paired_data)

# 將結果輸出為 CSV 檔案
write.csv(paired_data, "paired_result.csv", row.names = FALSE, fileEncoding = "Big5")

# 顯示結果
print(paired_data)
### ===============================
