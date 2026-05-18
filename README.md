# rk.tidycensus

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.tidycensus/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.tidycensus/actions/workflows/lintr.yml)
![AI Gemini](https://img.shields.io/badge/AI-Gemini-4285F4?logo=googlegemini&logoColor=white)

**An RKWard GUI Plugin for US Census Bureau Data Extraction and Spatial Mapping**

`rk.tidycensus` provides a seamless, point-and-click graphical interface inside RKWard to download microdata, socio-economic indicators, and spatial geometries from the US Census Bureau. Acting as a GUI wrapper for the powerful [`tidycensus`](https://walker-data.com/tidycensus/) R package by Kyle Walker, this plugin allows users to fetch, clean, and map census data without writing a single line of code.

This package includes a **multi-component workflow**: it not only downloads the data but also provides a dedicated plotter to map the spatial outputs instantly.

---

## 🌟 Key Features

* **Zero-Code Data Fetching:** Easily query the Decennial Census, ACS 1-Year, and ACS 5-Year estimates.
* **Granular Filtering:** Target data at the State, County, or Tract level using FIPS codes or text filters.
* **Spatial Ready (`sf`):** Automatically downloads and attaches boundary shapefiles to your census data (`geometry = TRUE`).
* **Built-in Smart Plotter:** Includes a custom mapping component that plots `tidycensus` objects directly without the need for manual spatial joins (`left_join`).
* **Silent & Cached Operations:** Automatically handles `tigris` caching and silences console clutter during heavy shapefile downloads.
* **Multilingual:** Fully translated into English, Spanish, French, German, and Portuguese (Brazil).

---

## ⚙️ Prerequisites

You must have [RKWard](https://rkward.kde.org/) installed along with the following R packages:

```R
install.packages(c("tidycensus", "sf", "ggplot2", "viridis"))
```

*Note: You will need a free **US Census Bureau API Key** to download data. You can request one [here](https://api.census.gov/data/key_signup.html).*

---

## 🚀 Installation

You can install this plugin directly from GitHub using `devtools`:

```R
# Install the plugin
devtools::install_github("AlfCano/rk.tidycensus")
```

Once installed, open RKWard, navigate to **Settings -> Configure RKWard -> Plugins**, and activate `rk.tidycensus`.

---

## 🛠️ Usage Workflow

This plugin adds two new tools to your RKWard menus, designed to be used in sequence:

### Step 1: Download US Census Data
**Navigate to:** `Data` ➔ `Official Statistics` ➔ `Download US Census Data`

1. **Setup & Source:** Paste your Census API key (or leave it blank if you already saved it in your `.Renviron`). Select your desired survey (e.g., *ACS 5-Year*) and the Year.
2. **Geography & Variables:** Choose your geographic level (e.g., *County*). Optionally filter by State (e.g., *TX*). Add your Census variable codes in the matrix (e.g., `B01003_001` for Total Population).
3. **Output:** Ensure **"Download Spatial Geometry (sf)"** is checked and click **Submit**. The data will be downloaded and saved to your workspace (e.g., `us_census_data`).

### Step 2: Plot TidyCensus Map
**Navigate to:** `Plots` ➔ `Maps` ➔ `Plot TidyCensus Map`

Since `tidycensus` already binds the data to the spatial polygons, mapping is instantaneous:
1. **Data Input:** Select your newly downloaded `us_census_data` object. Choose the value column you want to map (usually `estimate`).
2. **Appearance:** Select a color palette (e.g., *Viridis*), add a Map Title, and customize the Legend.
3. **Output & Export:** Preview the map instantly or export it directly as a high-resolution PNG or SVG. Click **Submit**.

---

## 🌍 Internationalization (i18n)

The graphical interface automatically adapts to your RKWard language settings. Currently supported languages:
* 🇺🇸 English (Default)
* 🇪🇸 Spanish (Español)
* 🇫🇷 French (Français)
* 🇩🇪 German (Deutsch)
* 🇧🇷 Portuguese (Português do Brasil)

---

## 📝 License and Author

**Author:** Alfonso Cano ([@AlfCano](https://github.com/AlfCano))  
**Email:** alfonso.cano@correo.buap.mx  
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)

This project is licensed under the **GPL (>= 3)** License.  
*Disclaimer: This package is a third-party GUI tool and is not officially affiliated with the US Census Bureau.*
