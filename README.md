# Northern Ireland Lucas Wedge

## Overview

This repository contains empirical data and analysis on the economic output (GVA and GDP) for all regions of the United Kingdom. The purpose of which is to calculate the [Lucas Wedge](https://en.wikipedia.org/wiki/Lucas_wedge) regarding the lack of a Northern Irish Executive since January 2017.

## Data

All data used in this study can be found in the [`data`](https://github.com/cbi-ni/ni-lucas-wedge/tree/master/data) directory of this repository. Specifically, we pull from three main data sources:

- Long-term regional quarterly Gross Value Added figures across the UK from 2010--2016 (ONS).

- UK-wide Gross Domestic Product figures from 1960--2018 (ONS).

- Projected GVA growth for Northern Ireland from 2019--2021 (Danske Bank & Oxford Economics).

## Results

Using an Autoregressive model ([ARIMA](https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average)) with fixed effects to capture and compensate for Brexit-related impacts, we find the following Deadweight less schedule.

| Year | GVA (£m) | Deadweight loss | Percentage of GVA (%) |
|------|----------|-----------------|-----------------------|
| 2017 | 38175    | 131.06          | 0.34                  |
| 2018 | 38905    | 412.82          | 1.06                  |
| 2019 | 39648    | 657.96          | 1.66                  |
| 2020 | 40048    | 1236.54         | 3.09                  |
| 2021 | 40571    | 1688.25         | 4.16                  |

By the end of 2019, the estimated cumulative deadweight loss from the lack of NI Executive will be approximately £1.2 billion. As uncertainty mounts and investment levels fall, by 2022 the cumulative deadweight loss could reach £4 billion.

The Lucas Wedge can be shown graphically below:

<img src="https://raw.githubusercontent.com/cbi-ni/ni-lucas-wedge/master/images/deadweight-loss-plot.png" align="center" />

## Contact

Please contact [me](mailto:sims.owen@gmail.com) with regards any issues or queries that you have.
