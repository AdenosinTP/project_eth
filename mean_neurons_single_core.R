

# go on session -> set working directory -> choose directory 
# activate library for ggplot and plyr; if you don't have it -> install.packages("ggplot2")


library(ggplot2)
library(plyr)

# Function for reading the files 
files = list.files( pattern = "*.txt")
n = length(files)




# /////////////////////////// CORE 0  /////////////////////////////////

frequencies = lapply(files, function(x) {
  file = read.table(x, header = T)
  
  freq= rep(NA, 256)          # create an empty array long 255 full of zeros
  
  for (i in 0:255) {             # loop for the neurons (here total of 256 neurons)
    time_n = file$time[file$core_id==0 & file$neuron_id==i]  # select the time for different neuron id
    spikes = length(time_n)
    min = min(time_n)
    max = max(time_n)
    dtime.s = (max - min)/1000000
    single_freq = spikes/(dtime.s)
    freq[i+1] = single_freq        # exits the  frequency of neuron_id = i for the i neuron
  }
  
  mean_freq = mean(freq)
  variance = var(freq)
  upr = max(freq)
  lwr = min(freq)

  
  return(data.frame(mean_freq, variance, upr, lwr))

  })

df <- ldply(frequencies, data.frame)

c=1:8

df = cbind(df, data_n=c(1:8)*32-1) # number of files you are using, in my case 8 files; 0:255 by 32


ggplot() + geom_line(data=df, aes(data_n, mean_freq)) +
  geom_ribbon(data=df, aes(data_n, ymin=lwr, ymax=upr), alpha=0.3, inherit.aes = T) +
  labs(x="fValue", y = "Mean frequency [Hz]")
  labs(title = "Core 0") + theme(plot.title = element_text(hjust = 0.5, size=rel(2)))

ggsave("mean_neurons_freq_core_0.pdf", plot = last_plot())
