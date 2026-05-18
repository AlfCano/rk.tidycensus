// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(sf)){stop(" + i18n("Preview not available, because package sf is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(sf)\n");
	}	if(is_preview) {
		echo("if(!base::require(ggplot2)){stop(" + i18n("Preview not available, because package ggplot2 is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggplot2)\n");
	}	if(is_preview) {
		echo("if(!base::require(viridis)){stop(" + i18n("Preview not available, because package viridis is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(viridis)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        if (raw.indexOf("[[") > -1) {
            var match = raw.match(/\[\[\"(.*?)\"\]\]/);
            return match ? match[1] : raw;
        }
        return raw.split("$").pop();
    }
  
    var map_obj = getValue('inp_map_obj');
    var val_col = getCol('inp_val_col');
    var pal = getValue('drp_pal');
    var title = getValue('inp_title');
    var leg = getValue('inp_leg');

    if (leg === '') { leg = val_col; }

    echo("p <- ggplot2::ggplot(" + map_obj + ") +\n");
    echo("  ggplot2::geom_sf(ggplot2::aes(fill = .data[['" + val_col + "']]), color = 'white', size = 0.2) +\n");
    echo("  ggplot2::scale_fill_viridis_c(option = '" + pal + "', na.value = 'gray90', name = '" + leg + "') +\n");
    echo("  ggplot2::theme_void()\n");

    if (title !== '') {
        echo("p <- p + ggplot2::labs(title = '" + title + "')\n");
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Plot TidyCensus Map results")).print();	
	}
    if (is_preview) { echo("print(p)\n"); } else {
        var dev_type = getValue("device_type"); var w = getValue("dev_width"); var h = getValue("dev_height"); var res = getValue("dev_res"); var bg = getValue("dev_bg");
        echo("rk.graph.on(device.type=\"" + dev_type + "\", width=" + w + ", height=" + h + ", res=" + res + ", bg=\"" + bg + "\")\n");
        echo("print(p)\n"); echo("rk.graph.off()\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var savePlotObj = getValue("save_plot_obj");
		var savePlotObjActive = getValue("save_plot_obj.active");
		var savePlotObjParent = getValue("save_plot_obj.parent");
		// assign object to chosen environment
		if(savePlotObjActive) {
			echo(".GlobalEnv$" + savePlotObj + " <- p\n");
		}	
	}

}

