/* General styles */
	.gp_clearer {clear:both;}
	.gp_tablecontrols { 
		clear: both;
		font-size: 0.9em;
		height: 28px;
		padding: 5px 10px 0px 10px;
		position: relative;
	}
	.gp_pbTableHeader { background-color: #dddbdb; }
	.gp_newFlag { margin-left: 0.5em; color:red; font-size: 8pt; }
	.btnImportant:hover {
	    background-position: right -29px !important;
	}
	.nowrap{
		white-space: nowrap;
	}

/* For making sure map takes up full page */
	.sidebarCollapsed{
		padding: 0px !important;	
	}
	
/* Custom MapQuest Styles */
	.mqabasicwnd { max-width:550px; min-width:250px; }
	.mapTogglesWrapper{
		min-width: 0px !important;
	}
	.mqabasicwnd-client{ /*for map bubble when content is tall*/
		overflow-y: scroll;
	}

/* Custom Map Styles */
	.gp_tooltip{
		background-color:#fff;
		color: #333333;
		padding: 6px 8px 8px 8px;
		border:1px #f9f9f9 solid;
		border-radius: 2px;
		box-shadow: 0 3px 11px #888888;
		white-space: nowrap;
	}
	.poiTooltip{
		max-width: 280px;
	}
	.poiTooltipActions{
		margin: 5px 0; 
		padding: 5px; 
		background-color: #eaeaea; 
		line-height:1.5em;
	}
	.poiTooltipActions a{
		padding-right: 7px;
		display: inline-block;
	}
	.poiTooltipButtons{
		margin: 8px 0px 0px 0px;
	}
	.poiTooltipButtons input{
		margin: 0px 7px 7px 0px !important;
	}
	.poiTooltipButtons a{
		margin: 0px 7px 7px 0px !important;
	}
/* Mapped Data Tabs and Tables*/
	#actionButtonPanel{
		margin: 5px 3px 0px 3px;
	}
	#actionButtonPanel div{
		float: left;
		padding-bottom: 5px;
	}
	.addFilterIcon{
		cursor: pointer;
		position: relative;
		height: 16px;
		margin-top: -3px;
		width: 16px;
		top: 3px;
		left: 2px;
	}
	#childFilterTable{
		margin-top: 0px;
	}
	.dataFilterTable{
		width: 100%;
	}
	.dataFilterTable tbody td{
		padding: 0px 2px 0px 5px;
	}
	#dataFilterTable tr{
		cursor: move;
		height: 23px;
	}
	#dataFilterTable tbody tr:hover{
		background-color: #e3f3ff;
	}
	#dataTableDIV{
		border-bottom: solid 1px #7B9AAB;
	}
	#dataSetSearchActionBtn{
		margin: 0px 5px 0px 5px;
	}
	#filterCountTable tr{
		height: 23px;
	}
	#filterLogic{
		margin-left: 4px;
		margin-bottom: 5px;			
	}
	#filterLogic a{
		text-decoration: underline;
		cursor: pointer;
	}
	#filterLogic img{
		top: 4px;
		left: -3px;
	}
	.filterLogicImg{
		background-position: 0 -16px;
		/*background-image: url(/img/analytics/filterpanel/addFilterSprite.png);   Set in common.css */
	}
	.filterTableCount {
		padding: 2px 2px 3px 0px;
		font-weight: bold;
	}
	#FiltersDIVOuter{
		border-top: 2px solid #D5DFE5;
		margin-top: 6px;
		padding-top: 3px;
	}
	#filtersObject{
		display: none;
		margin-bottom: 8px;
	}
	#filtersChild{
		display: none;
		margin-top: 2px;
	}
	#filtersChildTitle{
		border-bottom: 1px solid black;
		font-weight: bold;
		margin-bottom: 6px;
		padding-left: 3px;
	}
	#filtersChildTitle img{
		top: 4px;
	}
	#gp_dataTablesNoData{
		display: inline-block;
		margin-top: 3px;
		margin-left: 12px;
	}
	.pbHeaderCustom{
		border-top: solid 3px #003F77;
	}
	.pbHeaderCustom .pbTitle{
		padding: 2px 0px 0px 8px;
	}
	.pbHeaderCustom .pbButton {
		padding: 5px 0px 6px 0px;
	}
	.pbHeaderCustom .btn{
		margin-left: 3px;
		margin-right: 3px;
	}
	#mappedDataButtons{
		float: right;
		padding-right: 6px;
		position: relative;
		z-index: 500;
	}
	#mappedDataTitle{
		display: inline-block;
		font-size: 16px;
		float: left;
		position:relative;
		margin-top: 0px;
		z-index: 500;
	}
	#noFilterAccessMsg,#noFiltersMsg{
		margin-top: 3px;
		display: none;
	}

/* Error message styles */
	#page\:pageMessages{
		margin-top: -10px;
		margin-bottom: 10px;
		display: inline-block;
		width: 100%;
	}
	.pageMessageRemote{
		margin-top: -10px;
		margin-bottom: 14px;
	}
	#noFilterAccess{
		display: none;

	}

/* Right click context menu */
	#mapContextMenu{
		background-color: white;
		cursor: pointer;
		box-shadow: 0 3px 11px grey;
		display:none;
		left: 600px;
		width: 160px;
		opacity: 0.97;
		position: absolute;
		top: 200px;
		z-index: 200;
	}
	.mapContextMenuItemSubItem{
		font-size: 10px;
		margin-top: 2px;
		padding-left: 8px;
	}
	#mapContextMenu hr{
		background-color: #b7b7b7;
		border: 0;
		height: 1px;
		margin: 2px 5px;
	}
	.mapContextMenuItem{
		cursor: pointer;
		padding: 8px 10px 8px 10px;
	}
	.mapContextMenuItem:hover{
		background-color: #d6e9fe;
	}

/* Data Set Edit section */
#addDataSetField{
	margin-left: 3px;
}
#dataSetEditSection{
	display: none;
	min-width: 713px;
}
.editDataSetTitle{
	font-size: 14px;
	font-weight: bold;
}
.editDataSetLabel{
	font-weight: bold;
	padding-right: 6px;
	text-align: right;
}
#dataSetEditTable tr{
	vertical-align: top;
}
#dataSetEditSettings tr{
	vertical-align: middle;
}
#dataSetFieldList{
	list-style-type: none;
	margin: 0;
	padding: 0;
	width: 355px;
}
#dataSetFieldList li{
	margin: 3px 3px 3px 0;
	color: black;
	float: left;
}
#dataSetFieldList li .fieldLabel{
	border-right: 1px solid #f1f1f1;;
	display: inline-block;
	padding: 2px 4px 2px 6px;
	background-color: #CAE0AA;
	border-radius: 13px 0px 0px 13px;
	cursor: move;
}
#dataSetFieldList li .removeDataSetField{
	background-color: #cae0aa;
	display: inline-block;
	padding: 2px 6px 2px 4px;
	border-radius: 0px 13px 13px 0px;
	cursor: pointer;
}
#dataSetFieldList li .removeDataSetField:hover{
	background-color: #9bc55f;
}

/* Multi button filter option */
.multiButtonOptionImg{
	/*background-image: url(/img/analytics/filterpanel/addFilterSprite.png);   Set in common.css*/
	background-position: 0 0;
	width: 16px;
	height: 16px;
	background-repeat: no-repeat;
	background-color: transparent;
	top: -8px;
	left: -3px;
	position: relative;
}
.filterLogicImg{
	background-position: 0 -16px;
}
.crossfilterLogicImg{
	background-position: 0 -32px;
}
.multiButtonOptionText{
	display: inline-block;
}
.multiButtonOptionSubText{
	font-size: 11px;
}

/* Draw */
#drawModeSection{
	display: none;
}
.drawToolOption:active{
	background: #E4E4E4;
}
#drawSectionDataSetName{
	color: #242222;
	font-size: 10px;
	padding-left: 2px;
	max-width: 140px;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}
.saveShapeLabel{
	font-weight: bold;
	vertical-align: top;
	text-align: right;
	padding-top: 4px;
	padding-right: 4px;
	min-width: 90px
}
#shapeBubbleTitle{
	font-size: 12px;
}
#shapeBubbleDescription{
	font-size: 11px;
	margin: 3px 0px 4px 0px;
}
.shapeEditButtons input{
	margin-right: 2px !important;
}
	
/* Map Controls */
	.actionLink{
		color: #015ba7 !important;
		text-decoration: none;
		font-weight: normal;
	}
	.actionLinkDisabled{
		color: grey !important;
		cursor: default;
	}
	.actionLinkDisabled:hover{
		text-decoration: none;
	}
	#addFilterWrapper{
		float:left;
		margin-left: 6px;
		margin-top: -2px;
	}
	.centerContextTitle{
		font-size: 14px;
		font-weight: bold;
	}
	#editDataSetBtn{
		float:left;
		margin-left: 4px;
	}
	#dataSetEditButtons{
		text-align: center;
		padding-bottom: 3px;
	}
	.fieldSet{
		border: 1px solid #d5dfe5;
		border-radius: 4px;
		-mox-border-radius: 4px;
		-webkit-border-radius: 4px;
		position: relative;
		margin-top: 5px;
		margin-right: 5px;
	}
	.fieldSetContent{
		padding: 12px 10px 9px 10px;
		border: solid #1d1060;
		border-width: 0;
	}
	.fieldSetTitle{
		left: 0.5em;
		top: -0.7em;
		position: absolute;
		background: #fff;
		font-weight: bold;
		padding: 0 0.25em 0 0.25em;
	}
	.fieldSetTitleFilter{
		float:left;
	}
	#filterCountBubble{
		padding: 0px 4px 0px 4px;
		position: relative;
		top:0px;
		left: 0px;
	}
	.floatingTableHeaders{
		position: absolute;
		background-color: white;
		z-index: 10;
	}
	.geocodeQualityTitle{
		position: relative;
		top: 1px;
	}
	#gpHelpList{
		padding-left: 0px;
		margin: 7px 0px 0px 6px;
	}
	#gpHelpList li{
		padding: 4px;
	}
	#gpHelpLogo{
		height: 43px;
		margin-top: -5px;
		margin-bottom: 8px;
	}
	#gp_dataTableRoute_wrapper{
		overflow-y: scroll;
	}
	#gp_dataTableRoute_wrapper::-webkit-scrollbar-thumb {
		background-color: #CFCFCF;
		border-radius: 7px;
	}
	#gp_dataTableRoute_wrapper::-webkit-scrollbar {
		width: 7px;
		border-radius: 7px;
	}
	.helpIconCol{
		min-width: 44px;
		text-align: center;
		vertical-align: top;
	}
	.hiddenJSON{
		display: none;
	}
	.locationActionCol{
		width: 165px;
	}
	.locationDelLink, .locationName{
		padding-right: 8px;
	}
	#legendContent{
		overflow-y: auto;
	}
	.legendIcon{
		float: left;
		height: 30px;
		width: 133px;
	}
	.legendIconImg{
		float: left;
		margin-right: 3px;
	}
	.legendIconLabel{
		float: left;
		line-height: 23px;
		overflow: hidden;
		width: 115px;
		white-space: nowrap;
	}
	#legendPanel{
		min-width: 475px;
	}
	.legendSubHeader{
		font-weight: bold;
		text-decoration: underline;
		margin-bottom: 4px;
	}
	.mapControlTitleBar{
		border-bottom: 2px solid #D5DFE5;
		font-size: 12px;
		margin-bottom: 5px;
		padding: 0px 4px 5px 4px;
	}
	#mapShadowTop{
		box-shadow: 0 0 6px black;
		-moz-box-shadow: 0 0 6px black;
		-webkit-box-shadow: 0 0 6px black;
	    height: 7px;
	    position: absolute;
	    top: -7px;
	    width: 100%;
	    z-index: 51;e;
		z-index: 51;
	}
	#mapWrapper{
	    overflow: hidden;
		position: relative;	
	}
	.mapControl{
		min-width: 475px;
	    position: absolute;
	}
	.mapControlContent{
	    background-color: white;
	    border-radius: 0 0 4px 4px;
	    -moz-border-radius: 0 0 4px 4px;
	    -webkit-border-radius: 0 0 4px 4px;
	    box-shadow: 0 3px 11px #888888;
	    -moz-box-shadow: 0 3px 11px #888888;
	    -webkit-box-shadow: 0 3px 11px #888888;
	    padding: 5px;
	}
	.mapControlTab{
	    background-color: white;
	    border-radius: 0 0 4px 4px;
	    -moz-border-radius: 0 0 4px 4px;
	    -webkit-border-radius: 0 0 4px 4px;
	    box-shadow: 0 5px 4px 0 #888888;
	    -moz-box-shadow: 0 5px 4px 0 #888888;
	    -webkit-box-shadow: 0 5px 4px 0 #888888;
	    cursor: pointer;
	    height: 45px;
	    left: 8px;
	    margin-left: 8px;
	    
	    position: absolute;
	    text-align: center;
	    width: 50px;
	    -webkit-touch-callout: none;
		-webkit-user-select: none;
		-khtml-user-select: none;
		-moz-user-select: none;
		-ms-user-select: none;
		user-select: none;
	}
	.mapControlTabIcon{
		margin-top: 5px;
	}
	.floatingTableHeaders thead th{
		cursor: default;
	}
	.noRightMargin{
		margin-right: 0px;
	}
	.openMapControl{
		width: 25px;
		height: 25px;
		position: absolute;
		cursor: pointer;
	}
	#radialCenterIconSmall{
		height: 26px;
		position: absolute;
		top: 9px;
	}
	#radialSearchOptions{
		font-size: 11px;
		width: 260px;
	}
	.routeActionIcon{
		cursor:pointer;
		height: 25px;
		margin-top: 8px;
	}
	.countBubble{
		position: absolute;
		top: 25px;
		left: 29px;
		background-color: #f89406;
		padding-right: 5px;
		padding-left: 5px;
		padding-top: 1px;
		padding-bottom: 1px;
		border-radius: 9px;
		display: inline-block;
		font-size: 11px;
		font-weight: bold;
		line-height: 14px;
		color: #ffffff;
		text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.25);
		white-space: nowrap;
		vertical-align: baseline;
	}
	.countBubbleTab{
		position: static;
	}
	.saveDetail{
		font-size: 10px;
	}
	#saveDataSetBtn{
		float:left;
		margin-left: 2px;
	}
	.scrollableTableWrapper{
		overflow-y: auto;
	}
	.scrollableTableWrapper::-webkit-scrollbar-thumb {
		background-color: #CFCFCF;
		border-radius: 7px;
	}
	.scrollableTableWrapper::-webkit-scrollbar {
		width: 7px;
		border-radius: 7px;
	}
	.searchIconCol{
		cursor: pointer;
		min-width: 44px;
		text-align: center;
		vertical-align: middle;
	}
	.searchInput{
		font-size: 1.1em;
		margin-right: 8px;
		padding: 1px 1px 1px 3px;
		width: 380px;
	}
	.searchSeperator{
		border: 0;
	    height: 1px;
	    margin: 2px;
	    background: #d5dfe5;
	    background-image: -webkit-linear-gradient(left, #f5f7f9, #d5dfe5, #f5f7f9); 
	    background-image:    -moz-linear-gradient(left, #f5f7f9, #d5dfe5, #f5f7f9); 
	    background-image:     -ms-linear-gradient(left, #f5f7f9, #d5dfe5, #f5f7f9); 
	    background-image:      -o-linear-gradient(left, #f5f7f9, #d5dfe5, #f5f7f9); 
	}
	.settingsLabel{
		text-align:right;
		height: 18px;
	}
	.settingsValue{
		padding-left: 4px;
		text-align:left;
	}
	#showHideFiltersImg{
		background-position: 0 0;
		width: 16px;
		background-repeat: no-repeat;
		background-color: transparent;
		top: 4px;
		position: relative;
	}
	#messageBanner{
		background-color: #FFFDCB;
		border: 1px solid #DAE3E8;
		border-radius: 4px;
		padding: 4px;
		margin: 0px 0px 5px 0px;
		font-weight: bold;
	}
	#messageBanner .exclamation{
		color: red;
	}
	#messageBanner .hide{
		float: right;
		font-weight: normal;
		font-size: 11px;
		text-decoration: none;
		border: 1px solid #074980;
		border-radius: 4px;
		padding: 0px 2px 0px 2px;
	}
	
/* Custom Route Tab and Narrative Styles */
	#removeRouteButtons{
		display:none;
		padding: 11px 13px;
	}
	#removeRouteButtons input{
		margin-right: 10px;
	}
	#routeDirectionsIcon{
		height: 18px;
		margin-left: 6px;
		margin-top: -2px;
		vertical-align: middle;
	}
	#routeDirectionsTab{
		padding-top: 1px;
	}
	#routeNarrativeDIV{
		padding: 12px 14px;
	}
	#routeRecalcNeeded{
		display:none;
		font-size: 13px;
		margin: 12px 14px 0px 14px;
	}
	.tabShowHideIcon{
		border: 1px solid #D5D5D5;
		vertical-align: middle;
		height: 10px;
		padding: 3px;
		border-radius: 17px;
		margin-top: -2px;
		margin-left: 5px;
		cursor: pointer;
	}
	.tabHideIcon:hover{
		background-color: #F1B5B3;
		border: 1px solid #D56D68;
	}
	.tabShowIcon{
		display:none;
	}
	.tabShowIcon:hover{
		background-color: #BAE0BF;
		border: 1px solid #255727;
	}
	.tabDataHidden{
		text-decoration: line-through;
		font-weight: normal;
		margin: 0px 2px 0px 3px;
	}
	.tabRouteHidden{
		text-decoration: line-through;
		font-weight: normal;
		margin: 0px 1px 0px 1px;
	}

/* Layers tab */
	.layerGreenDot{
		position: relative;
		float: left;
		top: 3px;
		padding-right: 6px;
	}

/* Remove Data Set Tabs */
	.removeDataSetSearchButtons{
		display: none;
		padding: 11px 13px;
	}
	.removeDataSetSearchButtons input{
		margin-right: 10px !important;
	}

	
	table.dirImageTable { margin:5px auto; }
	div.dirRouteWarnings { background-color: lightyellow; padding: 5px; width: 1000px; }
	
	td.dirTitleMQ { background: #333333; color: white; padding: 10px; }
	td.dirTitleMQ span { font-size: 1.2em; font-weight: bold; }
	
	td.dirTotalTimeMQ { font-size: 1.1em; background: #A9A9A9; padding: 10px; }
	div.dirTotalTimeGOOG { background-color:#eeeeee; margin: 0 0 10px 0; padding: 10px 0px; border: thin solid silver; width: 1000px; }
	
	td.dirLegSummaryMQ { font-size: 1.1em; background: #DFDFDF; padding: 5px 10px; }
	table.dirLegSummaryGOOG { border: 1px solid silver; width: 1000px; margin: 10px 0px; background-color: rgb(238, 238, 238); border-collapse: collapse; color: rgb(0, 0, 0); }
	
	td.dirManeuverMQ { vertical-align: middle; border-bottom: 1px solid #CCCCCC; padding-bottom: 3px; }
	td.dirManeuverThumbMQ { vertical-align: middle; border-bottom: 1px solid #CCCCCC; padding: 7px 0px; }
	table.dirManeuverGOOG { margin: 0px; padding: 0px; width: 1000px; border-collapse: collapse; }

/* Chart styles */
.chartPanel{
	display:none;
	padding: 7px 7px 7px 10px;
}
.chartDiv{
	float: left;
	position: relative;
}
.chartDivWrapper{
	border: 1px solid #d5d5d5;
	float: left;
	margin-left: 18px;
}
.chartControls{
	float: left;
}
.chartControlLabel{
	font-weight: bold;
	text-align: right;
	vertical-align: top;
	padding-top: 4px;
}
.chartStacking{
	display:none;
}
.chartTypeImg{
	cursor: pointer;
	border: 1px solid white;
	height: 40px;
	padding: 2px;
}
.chartTypeImg.selected{
	border: 1px solid #0B6FCE;
}
.closeChart{
	border: 1px solid white;
	border-radius: 4px;	
	float:left;
	margin-top: 10px;
	margin-right: 9px;
	cursor: pointer;
	opacity: 0.5;
}
.closeChart:hover{
	opacity: 1.0;
	background-color: #F1B5B3;
	border: 1px solid #D56D68;
}
.showChartBtn{
	float: left;
	margin-left: 25px !important;
	margin-top: 0px !important;
}
.showChartBtn img{
	height: 17px;
}
.stackingImg{
	cursor: pointer;
	height: 40px;
	margin-right: 6px;
	border: 1px solid white;
}
.stackingImg.selected{
	border: 1px solid #0B6FCE;
}
.stackingImg.disabled{
	opacity: 0.30;
	filter: alpha(opacity=30);
}
.chartMsg{
	display: none;
	float: left;
	height: 400px;
	font-size: 13px;
}
.chartMsg .gp-alert{
	margin: 4px 10px 0px 16px;
}

/* Action Record Selection */
#selectRecordsModeBtn{
	margin-right: 2px;
	margin-left: 5px;
	float: left;
	margin-top: 0px !important;
}

#recordSelectionModeMsg{
	background-color: #FFFFA5;
	bottom: 0;
	border-radius: 4px 0px 0px 0px;
	border-top: 1px solid rgb(182, 182, 0);
	box-shadow: 0 0px 10px #888888;
	border-left: 1px solid rgb(182, 182, 0);
	display:none;
	position: absolute;
	right: 0;
	padding: 8px;
	z-index: 5;
}

/* Sortable table header style */
	table.sortable thead { cursor: pointer; }

/* Tab Styles for related list tabs */
	#relatedListsTabs{
		border: none;
	}
	#relatedListsTabs .ui-widget-header{
		border: 1px solid #7b9aab;
	}
	#relatedListsTabs .ui-widget-header{
	    background: transparent; 
	    border-width: 0px 0px 1px 0px; 
	    margin-bottom: 8px;
	    -moz-border-radius: 0px; 
	    -webkit-border-radius: 0px; 
	    border-radius: 0px; 
	}
	#relatedListsTabs .ui-tabs-panel { 
	    background: white; 
	    border-width: 0px; 
	}
	#relatedListsTabs li {
		background: white !important;
	}


/* Tab Bar jQuery UI theme overrides */
	#gp_dataTableTabs {
		font-size: 12px;
		font-family: Arial,Helvetica,sans-serif;
		margin-top: -32px;
		padding: 0px; 
	    background: none; 
	    border-width: 0px; 
	}

	/*Bottom border of tabs */
	#gp_dataTableTabs .ui-widget-header {
		border: 1px solid #7b9aab;
	}
	#gp_dataTableTabs .ui-tabs-nav { 
	    padding-left: 115px; 
	    padding-right: 370px;
	    background: transparent; 
	    border-width: 0px 0px 1px 0px; 
	    -moz-border-radius: 0px; 
	    -webkit-border-radius: 0px; 
	    border-radius: 0px; 
	} 
	#gp_dataTableTabs .ui-tabs-panel { 
	    background: white; 
	    border-width: 0px; 
	}

	/* Pevent blue outline when tab is selected */
	.ui-tabs .ui-tabs-nav li a {outline: none; }

	/*Tab content */
	.ui-tabs .ui-tabs-panel {
		padding: 0px;
	}
	/* list of tabs */
	.ui-tabs .ui-tabs-nav li {
		margin: 1px .3em 0 0;
	}
	/*Default tab*/
	.ui-state-default, .ui-widget-content .ui-state-default, .ui-widget-header .ui-state-default {
		border: 1px solid #D5DFE5;
		background: white;
		font-weight: bold;
		color: #333333;
	}
	.ui-state-default a, .ui-state-default a:link, .ui-state-default a:visited {
		color: #333333;
		text-decoration: none;
		opacity: 0.5;
		-ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=50)";
    	filter: alpha(opacity=50);
	}
	/*Selected Tab*/
	.ui-state-active, .ui-widget-content .ui-state-active, .ui-widget-header .ui-state-active {
		border: 1px solid #7b9aab;
		background: white;
		font-weight: bold;
		color: #333333;
	}
	.ui-state-active a, .ui-state-active a:link, .ui-state-active a:visited {
		color: #333333;
		text-decoration: none;
		opacity: 1.0;
		-ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)";
    	filter: alpha(opacity=100);
	}

/* jQuery UI tabs inside map control panels */
	.layerTab{
		border: 1px solid #d5dfe5 !important;
		border-radius: 4px !important;
		padding: 12px 10px 9px 10px !important;
	}

	.mapControlUITabs .ui-widget-header {
		background-color: white;
		background: white;
		border:none;
	}
	
	.mapControlUITabs {
		border: none !important;
		background: white;
		color: #222;
		padding: 0px;
		font-size: 12px;
		font-family: Arial,Helvetica,sans-serif;
		margin-top: -3px;
	}

	.mapControlUITabs .ui-tabs-panel .ui-widget-content .ui-corner-bottom{
		border: 1px solid black !important;
	}

/* Slider jQuery UI theme overrides */
	.ui-slider .ui-slider-range { background: #003F77; }

/* Demographics */
	#gp_demoTabs { font-size: 9pt; }
	.demoLabel{
		height: 20px;
		font-weight:bold;
		font-size: 90%;
		text-align: right;
	}
	.demoFixedLabel{
		width: 85px;
	}
	.demoValue{
		text-alignt: left;
	}
	#gp_demoFillOpacity,#gp_demoBorderOpacity{
		font-size: 11px;
		margin-left: 5px;
	}
	
/* jQuery Data Tables Styles */
	table thead tr.headerRow { cursor: pointer; } /* so mouse changes when sorting */
	table.display, table.gp_dataTable { margin: 0; } /* original CSS had it centering in the DIV */
	tr.odd { background-color: transparent; } /* do not alternate row colors */
	tr.even { background-color: transparent; } /* do not alternate row colors */
	table.display td, table.gp_dataTable td { padding:4px 2px 4px 5px; } /* copy padding of Salesforce table */
	table.display tbody tr.even:hover, table.gp_dataTable tbody tr.even:hover { background-color: #E3F3FF; } /* hover colors */
	table.display tbody tr.odd:hover, table.gp_dataTable tbody tr.odd:hover { background-color: #E3F3FF; } /* hover colors */
	table.gp_dataTableRoute {max-width: 1000px !important;}
	table.gp_dataTableRoute td {vertical-align: middle !important;}
	table.nostyle td {border:0 !important; padding:1px !important;}
	
	/* Copies and tweaks from the default CSS that comes with Data Tables */
	.dataTables_processing {
		position: absolute;
		top: 50%;
		left: 50%;
		width: 250px;
		height: 30px;
		margin-left: -125px;
		margin-top: -15px;
		padding: 14px 0 2px 0;
		border:1px solid navy;
		text-align: center;
		color:navy;
		font-size: 14px;
		background-color:#F8F8F8;
	}
	
	.dataTables_wrapper { 	
		position: relative;
		min-height: 0px;
		clear: both; 
		_height: 0px; 
		zoom: 1; /* Feeling sorry for IE */
	}
	
	.dataTables_info_dsname { font-weight: bold; color: #B00303; font-size: 1.1em; }
	.dataTables_info { 
		width: 505px;
		display: inline;
		float: left;
		font-size: 1.1em;
		padding: 4px 2px 2px 4px;
	}
	.dataTables_length { 
		float: left;
		padding-left: 20px;
		font-size: 12px;
	}
	.dataTables_paginate { display: inline; float: left; text-align: left;}
	.dataTables_filter { 
		float: left;
		font-weight: bold;
		padding-left: 20px;
		font-size: 12px;
	}
	.dataTables_filter input{
		font-size: 11px;
	}
	.dataTables_empty { text-align: center; }
	.dataTables_scroll { clear: both; }
	.dataTables_scrollBody { *margin-top: -1px; }
	
	.paging_full_numbers { height: 22px; line-height: 22px; }
	
	.paging_full_numbers a.paginate_button, .paging_full_numbers a.paginate_active {
		border: none;
		border-radius: 4px;
		-webkit-border-radius: 4px;
		-moz-border-radius: 4px;
		padding: 4px 6px;
		margin: 0 3px;
		text-decoration:none;
		cursor: pointer;
		outline: none;
		*cursor: hand;
	}
	
	.paging_full_numbers a.paginate_button { background-color: #ddd; }
	.paging_full_numbers a.paginate_button:hover { background-color: #ccc; }
	.paging_full_numbers a.paginate_active { background-color: #99B3FF; }

	#gp_dataTables .gp_dataTable th{
		outline: none;
	}

/* jGrowl Overrides */
	div.jGrowl div.jGrowl-notification { width: 400px; font-size: 1.2em; font-family: Arial, Helvetica, Tahoma, sans-serif; background-color: black; border: none; }
	div.jGrowl div.jGrowl-closer { background-color: black; border: none; }
	div.jGrowl div.jGrowl-notification div.close { font-size: 1em; cursor: pointer; float: right; font-weight: bold; z-index: 99;}
	div.jGrowl div.message { background-color: transparent; border: none; color: white; }
	
/* jQuery Tooltip */
	#tooltip {
		position: absolute;
		z-index: 3000;
		border: 2px solid #d9831b;
		background-color: #ffffff;
		padding: 4px 8px 0px 8px;
		opacity: 1;
		width: 400px;
		border-radius: 2px;
		-moz-border-radius: 2px;
		-webkit-border-radius: 2px;
		box-shadow: 0px 0px 35px -14px;
		-moz-box-shadow: 0px 0px 35px -14px;
		-webkit-box-shadow: 0px 0px 35px -14px;
	}
	#tooltip h3, #tooltip div { 
		padding: 4px 0px 10px 0px;
	}	
	#tooltip .body{
		padding: 0px;
	}