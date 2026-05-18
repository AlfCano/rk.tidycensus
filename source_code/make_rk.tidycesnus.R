local({
  # =========================================================================================
  # 1. Setup and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  plugin_name <- "rk.tidycensus"

  about_info <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "Download microdata from US Census Bureau and plot spatial data seamlessly.",
      version = "0.0.2",
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.tidycensus",
      license = "GPL (>= 3)"
    )
  )

  dependencies_node <- rk.XML.dependencies(
    dependencies = list((R.min = "3.5.0")),
    package = list(
      c(name = "tidycensus"),
      c(name = "sf"),
      c(name = "ggplot2"),
      c(name = "viridis")
    )
  )

  # JS Helper shared across components (from rk.rnaturalearth)
  js_helpers <- '
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        if (raw.indexOf("[[") > -1) {
            var match = raw.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
            return match ? match[1] : raw;
        }
        return raw.split("$").pop();
    }
  '

  # =========================================================================================
  # 2. MAIN COMPONENT: DOWNLOADER
  # =========================================================================================

  api_key <- rk.XML.input(label = "US Census API Key (leave empty if stored in .Renviron)", id.name = "inp_apikey")
  dataset <- rk.XML.dropdown(label = "Data Source", options = list("American Community Survey (ACS 5-Year)" = c(val="acs5", chk=TRUE), "American Community Survey (ACS 1-Year)" = c(val="acs1"), "Decennial Census" = c(val="decennial")), id.name = "drop_dataset")
  year <- rk.XML.spinbox(label = "Year", min=2000, max=2025, initial=2022, id.name = "spin_year")
  tab1_setup <- rk.XML.col(api_key, dataset, year)

  geo_level <- rk.XML.dropdown(label = "Geography Level", options = list("State" = c(val="state", chk=TRUE), "County" = c(val="county"), "Tract" = c(val="tract")), id.name = "drop_geo")
  state_filter <- rk.XML.input(label = "State Filter (Optional, e.g., 'TX' or 'Texas')", id.name = "inp_state")
  county_filter <- rk.XML.input(label = "County Filter (Optional, e.g., 'Harris')", id.name = "inp_county")
  var_matrix <- rk.XML.matrix(label = "Census Variable Codes (e.g., B01003_001)", mode = "string", min = 0, horiz_headers = c("Variable"), id.name = "mat_vars")
  tab2_geovars <- rk.XML.col(geo_level, state_filter, county_filter, var_matrix)

  get_geom <- rk.XML.cbox(label = "Download Spatial Geometry (sf) ready for mapping", value="TRUE", un.value="FALSE", id.name = "cbox_geom")
  save_res <- rk.XML.saveobj(label = "Save data as", initial="us_census_data", chk=TRUE, id.name = "save_result")
  tab3_output <- rk.XML.col(get_geom, rk.XML.stretch(), save_res)

  main_tabbook <- rk.XML.tabbook(tabs = list("Setup & Source" = tab1_setup, "Geography & Variables" = tab2_geovars, "Output" = tab3_output))
  dialog_down <- rk.XML.dialog(main_tabbook, label="Download US Census Data")

  js_calc_down <- rk.paste.JS("
    var api = getValue('inp_apikey'); var dataset = getValue('drop_dataset'); var year = getValue('spin_year');
    var geo = getValue('drop_geo'); var state = getValue('inp_state'); var county = getValue('inp_county');
    var geom = getValue('cbox_geom'); var vars = getValue('mat_vars.0');

    if (api !== '') echo(\"census_api_key('\" + api + \"', install = TRUE)\\n\\n\");
    if (vars !== '') { var var_str = \"c('\" + vars.split('\\n').join(\"', '\") + \"')\"; echo(\"var_list <- \" + var_str + \"\\n\\n\"); } else { echo(\"var_list <- NULL\\n\\n\"); }

    echo(\"us_census_data <- \");
    if (dataset === 'decennial') { echo(\"get_decennial(\\n\"); } else { echo(\"get_acs(\\n  survey = '\" + dataset + \"',\\n\"); }
    echo(\"  geography = '\" + geo + \"',\\n\");
    if (vars !== '') echo(\"  variables = var_list,\\n\");
    echo(\"  year = \" + Math.floor(year) + \",\\n\");
    if (state !== '') echo(\"  state = '\" + state + \"',\\n\");
    if (county !== '') echo(\"  county = '\" + county + \"',\\n\");
    echo(\"  geometry = \" + geom + \"\\n)\\n\");
  ")

  js_print_down <- rk.paste.JS("
    var save_result = getValue('save_result');
    echo(\"cat('\\n========================================\\n')\\n\");
    echo(\"cat(' US CENSUS DATA DOWNLOAD SUCCESSFUL\\n')\\n\");
    echo(\"cat('========================================\\n')\\n\");
    echo(\"cat('Data saved to workspace object: \" + save_result + \"\\n\\n')\\n\");
    echo(\"preview_data <- head(us_census_data)\\n\");
    echo(\"if ('sf' %in% class(preview_data)) preview_data <- sf::st_drop_geometry(preview_data)\\n\");
    echo(\"print(as.data.frame(preview_data))\\ncat('\\n')\\n\");
  ")


  # =========================================================================================
  # 3. SECONDARY COMPONENT: PLOTTER
  # =========================================================================================

  var_sel_plot <- rk.XML.varselector(id.name = "v_sel_plot")
  inp_map_plot <- rk.XML.varslot(label = "TidyCensus Object (sf)", source = "v_sel_plot", required = TRUE, id.name = "inp_map_obj", classes = "sf")
  inp_val_plot <- rk.XML.varslot(label = "Value Column (e.g. estimate)", source = "v_sel_plot", required = TRUE, id.name = "inp_val_col")

  drp_pal_plot <- rk.XML.dropdown(label = "Color Palette", id.name = "drp_pal", options = list("Viridis (Default)"=list(val="D",chk=TRUE),"Magma"=list(val="A"),"Inferno"=list(val="B"),"Plasma"=list(val="C"),"Cividis"=list(val="E")))
  inp_title_plot <- rk.XML.input(label = "Map Title", id.name = "inp_title")
  inp_leg_plot <- rk.XML.input(label = "Legend Title (Leave empty for variable name)", id.name = "inp_leg")

  # Standard Output UI elements (Matching rnaturalearth)
  save_plot <- rk.XML.saveobj(label = "Save Plot Object", initial = "p", id.name = "save_plot_obj", chk = TRUE)
  preview_map <- rk.XML.preview(mode = "plot")
  export_frame <- rk.XML.frame(label = "Graphics Export Settings",
      rk.XML.dropdown(label = "Device type", id.name = "device_type", options = list("PNG" = list(val = "PNG", chk = TRUE), "SVG" = list(val = "SVG"))),
      rk.XML.row(rk.XML.spinbox(label = "Width (px)", id.name = "dev_width", min = 100, max = 4000, initial = 1200), rk.XML.spinbox(label = "Height (px)", id.name = "dev_height", min = 100, max = 4000, initial = 1000)),
      rk.XML.col(rk.XML.spinbox(label = "Resolution (ppi)", id.name = "dev_res", min = 50, max = 600, initial = 150), rk.XML.dropdown(label = "Background", id.name = "dev_bg", options = list("Transparent" = list(val = "transparent", chk = TRUE), "White" = list(val = "white"))))
  )

  tab1_plot_data <- rk.XML.col(inp_map_plot, inp_val_plot, rk.XML.stretch())
  tab2_plot_app <- rk.XML.col(drp_pal_plot, inp_title_plot, inp_leg_plot, rk.XML.stretch())
  tab3_plot_out <- rk.XML.col(export_frame, save_plot, preview_map)

  dialog_plot <- rk.XML.dialog(label="Plot TidyCensus Map", child=rk.XML.row(var_sel_plot, rk.XML.col(
      rk.XML.text("Plots sf objects directly without joining. Ideal for mapped TidyCensus outputs."),
      rk.XML.tabbook(tabs = list("Data Input" = tab1_plot_data, "Appearance" = tab2_plot_app, "Output & Export" = tab3_plot_out))
  )))

  js_calc_plot <- paste0(js_helpers, "
    var map_obj = getValue('inp_map_obj');
    var val_col = getCol('inp_val_col');
    var pal = getValue('drp_pal');
    var title = getValue('inp_title');
    var leg = getValue('inp_leg');

    if (leg === '') { leg = val_col; }

    echo(\"p <- ggplot2::ggplot(\" + map_obj + \") +\\n\");
    echo(\"  ggplot2::geom_sf(ggplot2::aes(fill = .data[['\" + val_col + \"']]), color = 'white', size = 0.2) +\\n\");
    echo(\"  ggplot2::scale_fill_viridis_c(option = '\" + pal + \"', na.value = 'gray90', name = '\" + leg + \"') +\\n\");
    echo(\"  ggplot2::theme_void()\\n\");

    if (title !== '') {
        echo(\"p <- p + ggplot2::labs(title = '\" + title + \"')\\n\");
    }
  ")

  js_print_plot <- "
    if (is_preview) { echo(\"print(p)\\n\"); } else {
        var dev_type = getValue(\"device_type\"); var w = getValue(\"dev_width\"); var h = getValue(\"dev_height\"); var res = getValue(\"dev_res\"); var bg = getValue(\"dev_bg\");
        echo(\"rk.graph.on(device.type=\\\"\" + dev_type + \"\\\", width=\" + w + \", height=\" + h + \", res=\" + res + \", bg=\\\"\" + bg + \"\\\")\\n\");
        echo(\"print(p)\\n\"); echo(\"rk.graph.off()\\n\");
    }
  "

  # We declare the plotter as an extra component mapped to the "Plots -> Maps" hierarchy
  comp_plotter <- rk.plugin.component("Plot TidyCensus Map", xml = list(dialog = dialog_plot), js = list(require = c("sf", "ggplot2", "viridis"), calculate = js_calc_plot, printout = js_print_plot), hierarchy = list("plots", "Maps"))

  # =========================================================================================
  # 4. Final Skeleton Assembly
  # =========================================================================================
  rk.plugin.skeleton(
    about = about_info,
    path = ".",
    # The Main Component (Downloader) is passed directly to the skeleton root
    xml = list(dialog = dialog_down),
    js = list(require = c("tidycensus"), results.header = FALSE, calculate = js_calc_down, printout = js_print_down),

    # Extra Components are passed here
    components = list(comp_plotter),

    # Pluginmap takes the exact name and target hierarchy of the MAIN component
    pluginmap = list(
        name = "Download US Census Data",
        hierarchy = list("data", "Official Statistics")
    ),

    dependencies = dependencies_node,
    create = c("pmap", "xml", "js", "desc", "rkh"),
    overwrite = TRUE,
    load = TRUE
  )
})
