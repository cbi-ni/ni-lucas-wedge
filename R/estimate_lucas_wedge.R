library(purrr)
library(readr)
library(ggplot2)
library(forecast)
library(magrittr)


#' BBC ONS growth rate: 0.9% (https://www.bbc.co.uk/news/uk-northern-ireland-47306884)
#' 
#' Danske Bank & Oxford economic assessment:  economic growth in Northern Ireland will average 1.0% in 2019 and 1.3% in 2020 (https://danskebank.co.uk/-/media/danske-bank/uk/business/economic-analysis/quarterly-sectoral/danske-bank-northern-ireland-quarterly-sectoral-forecasts-2019-q1-final-.-la=en.pdf)
#' 
#' Inflation from Bank of England report (https://www.bankofengland.co.uk/inflation-report/2018/august-2018/prospects-for-inflation)


DATA_PATH <- getwd() %>% 
  paste0("/data") 

NI_GROWTH_RATE = c(
  1.7, # CBI
  0.9, # BBC
  1.0, # Danske
  1.3) # Danske

BOE_INFLATION_RATE = c(
  2.4, 
  2.1,
  2.0,
  2.0)

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


calculate_regional_gva <- function(gvaData) {
  totalRegionalGva <- gvaData[21, 2:20] %>% 
    purrr::flatten_dbl()
  data.frame(
    year = 1998:2016,
    totalGVA = totalRegionalGva,
    executiveDummy = 1,
    stringsAsFactors = FALSE) %>%
    return()
}


estimate_lucas_wedge <- function(regional.gva.data) {
  lucasWedge <- c()
  regional.gva <- calculate_regional_gva(
    gvaData = regional.gva.data)
  projectedGva <- sapply(
    X = 1:(NI_GROWTH_RATE %>% length()), 
    FUN = function(x) {
      if (i == 1) {
        return((
          (NI_GROWTH_RATE[i] + 100) / 100) * 
            regional.gva$totalGVA[nrow(regional.gva)])
      } else {
        return((
          (NI_GROWTH_RATE[i] + 100) / 100) * 
            projectedGva[i-1])
      }
    }
  )
  counterfactual.projection <- regional.gva %$%
    totalGVA[1:19] %>%
    forecast::auto.arima() %>%
    forecast::forecast(4) %>%
    as.data.frame()
  for (i in 1:(deflatedForecast %>% length())) {
    lucasWedge %<>% 
      append(
        projected.regional.gva$totalGVA[19+i] - 
          counterfactual.projection$`Point Forecast`[i])
  }
  data.frame(
    year = 2017:2020,
    noExecutive = counterfactual.projection$`Point Forecast`,
    executive = projected.regional.gva$totalGVA[20:23],
    lucasWedge = lucasWedge) %>%
    return()
}


generate_lucas_wedge_chart <- function(lucas.wedge.data, regional.gva.data) {
  regional.gva <- calculate_regional_gva(
    gvaData = regional.gva.data)
  
  lucasWedgePlot <- data.frame(
    year = c(regional.gva$year, lucas.wedge.data$year) %>% 
      as.numeric() + 1,
    actual = c(regional.gva$totalGVA, lucas.wedge.data$noExecutive),
    counter = c(regional.gva$totalGVA, lucas.wedge.data$executive),
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
  paste0("/cbi-real-gva-ni-data.csv") %>% 
  read_csv()

lucasWedge <- estimate_lucas_wedge(
  regional.gva.data = regional.gva.data)

economicLossChart <- lucasWedge %>% 
  generate_economic_loss_chart()

lucasWedgePlot <- lucasWedge %>% 
  generate_lucas_wedge_chart(
    regional.gva.data = regional.gva.data)
