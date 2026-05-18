// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(tidycensus)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
	
    var api = getValue('inp_apikey'); var dataset = getValue('drop_dataset'); var year = getValue('spin_year');
    var geo = getValue('drop_geo'); var state = getValue('inp_state'); var county = getValue('inp_county');
    var geom = getValue('cbox_geom'); var vars = getValue('mat_vars.0');

    if (api !== '') echo("census_api_key('" + api + "', install = TRUE)\n\n");
    if (vars !== '') { var var_str = "c('" + vars.split('\n').join("', '") + "')"; echo("var_list <- " + var_str + "\n\n"); } else { echo("var_list <- NULL\n\n"); }

    echo("us_census_data <- ");
    if (dataset === 'decennial') { echo("get_decennial(\n"); } else { echo("get_acs(\n  survey = '" + dataset + "',\n"); }
    echo("  geography = '" + geo + "',\n");
    if (vars !== '') echo("  variables = var_list,\n");
    echo("  year = " + Math.floor(year) + ",\n");
    if (state !== '') echo("  state = '" + state + "',\n");
    if (county !== '') echo("  county = '" + county + "',\n");
    echo("  geometry = " + geom + "\n)\n");
  
}

function printout(is_preview){
	// printout the results
	
    var save_result = getValue('save_result');
    echo("cat('\n========================================\n')\n");
    echo("cat(' US CENSUS DATA DOWNLOAD SUCCESSFUL\n')\n");
    echo("cat('========================================\n')\n");
    echo("cat('Data saved to workspace object: " + save_result + "\n\n')\n");
    echo("preview_data <- head(us_census_data)\n");
    echo("if ('sf' %in% class(preview_data)) preview_data <- sf::st_drop_geometry(preview_data)\n");
    echo("print(as.data.frame(preview_data))\ncat('\n')\n");
  
	//// save result object
	// read in saveobject variables
	var saveResult = getValue("save_result");
	var saveResultActive = getValue("save_result.active");
	var saveResultParent = getValue("save_result.parent");
	// assign object to chosen environment
	if(saveResultActive) {
		echo(".GlobalEnv$" + saveResult + " <- us_census_data\n");
	}

}

