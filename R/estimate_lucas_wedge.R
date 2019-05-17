library(purrr)
library(readr)
library(ggplot2)
library(forecast)
library(magrittr)


DATA_PATH <- getwd() %>% 
  paste0("/data") 


percentage_change <- function(vector) {
  sapply(
    X = 1:length(vector), 
    FUN = function(x) { 
      if (x == 1) { 
        return(0) 
      } else {
        return((
          (vector[x] - vector[x-1]) / vector[x-1]) * 100)
      }
    }) %>%
    return()
}


calculate_regional_gva <- function(region, gvaData) {
  if (region != 'all') {
    gvaData %<>% 
      subset(Region == region)
  }
  totalRegionalGva <- sapply(
    X = gvaData[, 6:24], 
    FUN = sum) %>% 
    as.vector()
  gvaPercentageChange <- totalRegionalGva %>% 
    percentage_change()
  data.frame(
    year = gvaData[, 6:24] %>% 
      names(),
    totalGVA = totalRegionalGva,
    percentageChange = gvaPercentageChange,
    stringsAsFactors = FALSE) %>%
    return()
}


calculate_uk_gdp <- function(gdp.data, from = 1960) {
  years <- gdp.data$Year %>% 
    unique() %>%
    subset(. >= from)
  yearlyGDP <- sapply(
    X = years, 
    FUN = function(x) {
      yearlyData <- gdp.data %>% 
        subset(Year == x) 
      sum(yearlyData$GDP) %>% 
        return()
  })
  percentageChange <- yearlyGDP %>% 
    percentage_change()
  data.frame(
    year = years,
    totalGDP = yearlyGDP,
    percentageChange = percentageChange,
    stringsAsFactors = FALSE) %>%
    return()
}


estimate_lucas_wedge <- function(region, regional.gva.data, uk.gdp.data) {
  lucasWedge <- c()
  projected.gva.data <- regional.gva.data[
    regional.gva.data %>% 
      nrow(), 25:29] %>%
    purrr::flatten_dbl()
  regional.gva <- calculate_regional_gva(
    region = region, 
    gvaData = regional.gva.data)
  counterfactual.projection <- regional.gva$totalGVA %>%
    forecast::auto.arima() %>%
    forecast::forecast(
      projected.gva.data %>% 
        length()) %>%
    as.data.frame()
  for (i in 1:(projected.gva.data %>% length())) {
    lucasWedge %<>% 
      append(counterfactual.projection$`Point Forecast`[i] - projected.gva.data[i])
  }
  data.frame(
    year = 2017:2021,
    actual = projected.gva.data,
    counterfactual = counterfactual.projection$`Point Forecast`,
    lucasWedge = lucasWedge) %>%
    return()
}


generate_lucas_wedge_chart <- function(lucas.wedge.data, regional.gva.data) {
  regional.gva <- calculate_regional_gva(
    region = "Northern Ireland", 
    gvaData = regional.gva.data)
  
  lucasWedgePlot <- data.frame(
    year = c(regional.gva$year, lucas.wedge.data$year) %>% as.numeric() + 1,
    actual = c(regional.gva$totalGVA, lucas.wedge.data$actual),
    counter = c(regional.gva$totalGVA, lucas.wedge.data$counterfactual),
    stringsAsFactors = FALSE) %>% 
    subset(year >= 2014) %>%
    ggplot(
      mapping = aes(
        x = year %>% as.character(), 
        y = actual, 
        group = 1)) +
      geom_line(mapping = aes(
        y = actual,
        color = "No NI Executive")) +
      geom_line(mapping = aes(
        y = counter,
        color = "NI Executive")) + 
      geom_ribbon(
        mapping = aes(
          x = year %>% as.character(),
          ymin = counter, 
          ymax = actual), 
        fill = "yellow", 
        alpha = 0.2) +
      xlab("") + ylab("Real GVA (£m)") + 
      labs(title = "Economic output loss from a lack of NI Executive") + 
      ggthemes::scale_color_ptol() +
      ggthemes::scale_fill_ptol() +
      theme_minimal() +
      theme(
        legend.title = element_blank(), 
        legend.position = "bottom")
  
  return(lucasWedgePlot)
}


generate_economic_loss_chart <- function(lucas.wedge.data) {
  lucas.wedge.data %>%
    ggplot() +
    geom_line(mapping = aes(
      x = year, 
      y = lucasWedge)) +
    geom_point(mapping = aes(
      x = year, 
      y = lucasWedge)) +
    theme_minimal() +
    xlab("") +
    ylab("Deadweight loss (£m)") %>%
    return()
}


regional.gva.data <- DATA_PATH %>% 
  paste0("/gross-value-added-data.csv") %>% 
  read_csv()

uk.gdp.data <- DATA_PATH %>%
  paste0("/gross-domestic-product-data.csv") %>% 
  read_csv()

lucasWedge <- estimate_lucas_wedge(
  region = "Northern Ireland",
  regional.gva.data = regional.gva.data, 
  uk.gdp.data = uk.gdp.data)

economicLossChart <- generate_economic_loss_chart(
  lucas.wedge.data = lucasWedge)

lucasWedgePlot <- generate_lucas_wedge_chart(
  lucas.wedge.data = lucasWedge, 
  regional.gva.data = regional.gva.data)
