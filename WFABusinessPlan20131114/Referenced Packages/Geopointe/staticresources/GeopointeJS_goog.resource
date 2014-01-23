var gp_map; // holds the Map object
var gp_routeResultsData; // Holds route result data
var gp_routeRequestLocs; // Holds the route request locations
var gp_bestFitMaxZoom; // max zoom for bestFit. global var b/c we need it in a listener
var gp_forceBestFitMaxZoom = false; // whether the listener should use bestFitMaxZoom or not
var $tabsBeforeStreetView; //keep track of the tabs that where visible before entering street view

// For markers
var gp_markers; // all the map markers as an associative array
var gp_markersPlaces; // all Places  markers
var gp_masterMarker; // The Master Record's Marker - GMarker
var gp_searchMarker;
var gp_bounds; // holds the LatLngBounds object so we can center and zoom properly - GLatLngBounds
var gp_placeBounds; // holds bounds of Places
var gp_infoWindow; // a single info window object used on the map
var gp_tooltip; // a floating tooltip for the markers
var gp_cirOverlays; // all the Circle overlay as an associative array
var gp_kmlOverlays; // all the Circle overlay as an associative array
var gp_layers = {}; // object that contains url as key, and google layer object as value

// Demographics
var gp_demoConfig;
var gp_demoLayer; // The actual layer on the map

// For Routing
var gp_dir; // Directions Renderer object

// Layers
var gp_traffic;
var gp_trafficState = false;
var gp_transit;
var gp_transitState = false;
var gp_bicycling;
var gp_bicyclingState = false;
var gp_weather;
var gp_weatherState = false;


// For Drawing
var gp_drawingManager; // master drawing manager object

//Info about the jQuery Tabs
var gp_JQTabs = {
	"mapDataSets": 0,
	"search": 1,
	"layers": 2,
	"manualEntry": 3,
	"currentRoute": 4,
	"mySettings": 5
}

// Demographics Config
gp_demoConfig = { 
		"gradientColors": [
	                "#FFFFFA",
	                "#ffffcc",
	                "#ffeda0",
	                "#fed976",
	                "#feb24c",
	                "#fd8d3c",
	                "#fc4e2a",
	                "#e31a1c",
	                "#b10026",
	                "#800026",
	                "#66001E",
	                "#2D000D"
	            ],
		"metrics": [
	        {
	        	"min_block_group": 30,
	            "max_block_group": 55,
	            "min_tract": 30,
	            "max_tract": 55,
	            "min_county": 30,
	            "max_county": 50,
	            "min": 35,
	            "max": 40,
	            "label": "Age (Average)",
	            "name": "age_average"
	        },
	        {
	        	"min_block_group": 30,
	            "max_block_group": 55,
	            "min_tract": 30,
	            "max_tract": 55,
	            "min_county": 30,
	            "max_county": 50,
	            "min": 35,
	            "max": 40,
	            "label": "Age (Median)",
	            "name": "age_median"
	        },
	        {
	        	"min_block_group": 10,
	            "max_block_group": 60,
	            "min_tract": 10,
	            "max_tract": 60,
	            "min_county": 10,
	            "max_county": 50,
	            "min": 15,
	            "max": 40,
	            "label": "Commute Time (Average)",
	            "name": "commute_time_average"
	        },
	        {
	        	"min_block_group": 10000,
	            "max_block_group": 200000,
	            "min_tract": 10000,
	            "max_tract": 150000,
	            "min_county": 10000,
	            "max_county": 100000,
	            "min": 30000,
	            "max": 90000,
	            "label": "Household Income (Average)",
	            "name": "household_income_average"
	        },
	        {
	        	"min_block_group": 10000,
	            "max_block_group": 200000,
	            "min_tract": 10000,
	            "max_tract": 150000,
	            "min_county": 10000,
	            "max_county": 70000,
	            "min": 30000,
	            "max": 70000,
	            "label": "Household Income (Median)",
	            "name": "household_income_median"
	        },
	        {
	        	"min_block_group": 1,
	            "max_block_group": 6,
	            "min_tract": 1,
	            "max_tract": 6,
	            "min_county": 1.5,
	            "max_county": 4.5,
	            "min": 2,
	            "max": 3.5,
	            "label": "Household Size (Average)",
	            "name": "household_size_average"
	        },
	        {
	            "min_block_group": 1.5,
	            "max_block_group": 3,
	            "min_tract": 1.5,
	            "max_tract": 3,
	            "min_county": 1,
	            "max_county": 3,
	            "min": 1,
	            "max": 2.5,
	            "label": "Household Vehices (Average per)",
	            "name": "vehicles_per_household_average"
	        },
	        
	        {
	        	"min_block_group": 100,
	            "max_block_group": 1000,
	            "min_tract": 1000,
	            "max_tract": 5000,
	            "min_county": 10000,
	            "max_county": 200000,
	            "min": 1000000,
	            "max": 10000000,
	            "label": "Housing Units (Total)",
	            "name": "housing_units"
	        },
	        {
	        	"min_block_group": 30,
	            "max_block_group": 90,
	            "min_tract": 30,
	            "max_tract": 90,
	            "min_county": 30,
	            "max_county": 80,
	            "min": 40,
	            "max": 75,
	            "label": "Housing Units (% Owner Occupied)",
	            "name": "(owner_occupied_housing_units/housing_units)*100"
	        },
	        {
	        	"min_block_group": 10,
	            "max_block_group": 70,
	            "min_tract": 10,
	            "max_tract": 70,
	            "min_county": 20,
	            "max_county": 40,
	            "min": 25,
	            "max": 35,
	            "label": "Housing Units (% Renter Occupied)",
	            "name": "(renter_occupied_housing_units/housing_units)*100"
	        },
	        {
	            "min_block_group": 0,
	            "max_block_group": 5000,
	            "min_tract": 0,
	            "max_tract": 10000,
	            "min_county": 0,
	            "max_county": 1000000,
	            "min": 500000,
	            "max": 20000000,
	            "label": "Population (Total)",
	            "name": "population"
	        },
	        {
	        	"min": 0,
	            "max": 200,
	            "label": "Population (Per Square Mile)",
	            "name": "population/(area*0.386102159)"
	        },
	        {
	            "min": 35,
	            "max": 50,
	            "label": "Marital Status (% Married)",
	            "name": "(married/population)*100"
	        },
	        {
	            "min_block_group": 0,
	            "max_block_group": 25,
	            "min_tract": 0,
	            "max_tract": 25,
	            "min_county": 0,
	            "max_county": 20,
	            "min": 0,
	            "max": 20,
	            "label": "Marital Status (% Divorced)",
	            "name": "(divorced/population)*100"
	        },
	        {
	            "min": 0,
	            "max": 10,
	            "label": "Marital Status (% Widowed)",
	            "name": "(widowed/population)*100"
	        },
	        {
	            "min": 0,
	            "max": 50,
	            "label": "Marital Status (% Never Married)",
	            "name": "(never_married/population)*100"
	        },
	        {
	            "min": 0,
	            "max": 40,
	            "label": "Race (% African American)",
	            "name": "(black_or_african_american/population)*100"
	        },
	        {
	            "min": 0,
	            "max": 10,
	            "label": "Race (% American Indian / Alaska Native)",
	            "name": "(american_indian_or_alaska_native/population)*100"
	        },
	        {
	            "min": 0,
	            "max": 10,
	            "label": "Race (% Asian)",
	            "name": "(asian/population)*100"
	        },
	        {
	            "min": 0,
	            "max": 10,
	            "label": "Race (% Multi Race)",
	            "name": "(multi_race/population)*100"
	        },
	        {
	            "min": 0,
	            "max": 1,
	            "label": "Race (% Native Hawaiian / Pacific Islander)",
	            "name": "(native_hawaiian_or_pacific_islander/population)*100"
	        },
	        {
	            "min": 0,
	            "max": 10,
	            "label": "Race (% Other Race)",
	            "name": "(other_race/population)*100"
	        },
	        {
	            "min": 50,
	            "max": 100,
	            "label": "Race (% White)",
	            "name": "(white/population)*100"
	        }
		    ]
	};

function __MAPPING_STUFF__(){}
// re-init the global objects
function gp_initJSObjects(){
	if (typeof(gp_markers) == 'undefined'){gp_markers = new Object();}
	if (typeof(gp_bounds) == 'undefined'){gp_bounds = new google.maps.LatLngBounds();}
	if (typeof(gp_infoWindow) == 'undefined'){
		gp_infoWindow = new google.maps.InfoWindow({ maxWidth: 550 });
		google.maps.event.addListener(gp_infoWindow, 'domready', function() {
			jQuery('#gp_demoTabs').tabs();
			jQuery('#gp_demoTabs').show();

			//Find the shapeColor input field
			var $colorInput = jQuery(".gp_shapeColorInput");
			
			if($colorInput.length > 0){ //Only proceed if infowindow has a color input for a shape
				
				//Get the shape object from the polygonObjects object so we can default the
				var shapeId = $colorInput.attr('data-shapeId');
				var polygon = polygonObjects[shapeId];

				//Set starting color value and opacity on the input field
				$colorInput.val(polygon.fillColor);
				$colorInput.attr('data-opacity',polygon.fillOpacity);

				//Create color selector for the selected shape
				jQuery(".gp_shapeColorInput").minicolors({
					inline:true,
					opacity:true,
					theme: 'geopointe',
					change: function(hex, opacity){
						//Get overlay Id
						var overlayId = jQuery(this).attr('data-shapeId');

						//Set the color and opacity of the shap on the map
						polygonObjects[overlayId].setOptions({
							fillColor: hex,
							fillOpacity: opacity
						});
					}
				});
			}
		});
	}
	if (typeof(gp_tooltip) == 'undefined'){
		var ttOptions = {
			content: '',
			boxClass: 'gp_tooltip',
			closeBoxURL: '',
			isHidden: true
		}
		gp_tooltip = new InfoBox(ttOptions); // using the infoBox add-in
	}
	if (typeof(gp_cirOverlays) == 'undefined'){gp_cirOverlays = new Object();}
	if (typeof(gp_kmlOverlays) == 'undefined'){gp_kmlOverlays = new Object();}
}

//Clears the global variables out
function gp_cleanMapObjects(){
	for(var i in gp_markers) {
		gp_markers[i].setMap(null);

		//Remove checkbox marker if this marker has one
		if(gp_markers[i].selectedMarker){
			gp_markers[i].selectedMarker.setMap(null);
		}
	}
	gp_infoWindow.close();
	gp_tooltip.hide();
	for(var i in gp_cirOverlays) {
		gp_cirOverlays[i].setMap(null);
	}
	for(var i in gp_kmlOverlays) {
		gp_kmlOverlays[i].setMap(null);
	}
	
	gp_bounds = new google.maps.LatLngBounds();
	gp_markers = new Object();
	gp_cirOverlays = new Object();
	gp_kmlOverlays = new Object()
	
}

// Handles a Map Constructor
function gp_mapConstructor(jsAction){
	
	var thisMC = jsAction.mapConstructor;
	
	// Fix up the thisMC object as needed
	thisMC.startingZoom = 2;
	if (typeof(eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Zoom__c')) != 'undefined'){
		if (eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Zoom__c') != "") {
			thisMC.startingZoom = eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Zoom__c');
		}
	}
	
	thisMC.startingLat = 0;
	if (typeof(eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lat__c')) != 'undefined'){
		if (eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lat__c') != "") {
			thisMC.startingLat = eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lat__c');
		}
	}
	
	thisMC.startingLng = 0;
	if (typeof(eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lng__c')) != 'undefined'){
		if (eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lng__c') != "") {
			thisMC.startingLng = eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lng__c');
		}
	}
	
	thisMC.width = document.getElementById("mapWrapper").clientWidth;
	if (thisMC.height == "") { thisMC.height = 600;}
	
	if (thisMC.centerLat == null || thisMC.centerLat == ''){
		thisMC.centerLat = thisMC.startingLat;
	}
	
	if (thisMC.centerLng == null || thisMC.centerLng == ''){
		thisMC.centerLng = thisMC.startingLng;
	}
	
	if (thisMC.centerZoom == null || thisMC.centerZoom == ''){
		thisMC.centerZoom = thisMC.startingZoom;
	}
	
	// New Map Object
	if (thisMC.newMap){
		
		gp_map = null;
		document.getElementById('mapDIV').innerHTML = '';
		
		gp_bounds = new google.maps.LatLngBounds();
		
		var mapTypeIds = [];
        for(var type in google.maps.MapTypeId) {
            mapTypeIds.push(google.maps.MapTypeId[type]);
        }
        mapTypeIds.push("OSM");
        
		// Set map initial options
		var myOptions = {
			zoom: thisMC.startingZoom,
			center: new google.maps.LatLng(thisMC.startingLat, thisMC.startingLng),
			draggableCursor: 'default',
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			mapTypeControlOptions: {
                mapTypeIds: mapTypeIds,
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
            },
            scaleControl: true,
			scrollwheel: eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Use_Scrollwheel_Zoom__c'),
			overviewMapControl: true
		}
		
		// init the map
		gp_map = new google.maps.Map(document.getElementById("mapDIV"), myOptions);
		
		// OSM Tiles
		gp_map.mapTypes.set("OSM", new google.maps.ImageMapType({
            getTileUrl: function(coord, zoom) {
                return "http://tile.openstreetmap.org/" + zoom + "/" + coord.x + "/" + coord.y + ".png";
            	//return "https://otile1.mqcdn.com/tiles/1.0.0/osm/" + zoom + "/" + coord.x + "/" + coord.y + ".png";
            },
            tileSize: new google.maps.Size(256, 256),
            name: "Open Street Map",
            maxZoom: 18
        }));
		
		// Add layers
		gp_traffic = new google.maps.TrafficLayer();
		gp_transit = new google.maps.TransitLayer();
		gp_bicycling = new google.maps.BicyclingLayer();
		gp_weather = new google.maps.weather.WeatherLayer({
			temperatureUnits: google.maps.weather.TemperatureUnit.FAHRENHEIT
		});

		//Add drawing control
		gp_drawingManager = new google.maps.drawing.DrawingManager({
			drawingMode: google.maps.drawing.OverlayType.MARKER,
			drawingControl: false,
			drawingControlOptions: {
				position: google.maps.ControlPosition.TOP_CENTER,
				drawingModes: [
					google.maps.drawing.OverlayType.POLYGON,
					google.maps.drawing.OverlayType.RECTANGLE
				]
			},
			markerOptions: {
				icon: 'http://www.example.com/icon.png'
			},
			polygonOptions: {
				fillColor: '#EFFF79',
				fillOpacity: .2,
				strokeWeight: 1.5,
				clickable: true,
				zIndex: 1,
				editable: true,
				draggable: true
			}
		});

		//Add event listener when a polygon is added to the map after drawing is complete
		google.maps.event.addListener(gp_drawingManager, 'overlaycomplete', function(e) {
			gp_shapeAddedToMap(e.overlay);
		});

		// Event listener on zoom change to correct the zoom if needed
		google.maps.event.addListener(gp_map, 'zoom_changed', function() {
			zoomChangeBoundsListener = google.maps.event.addListener(gp_map, 'bounds_changed', function(event) {
				if (this.getZoom() > gp_bestFitMaxZoom && gp_forceBestFitMaxZoom) {
					this.setZoom(gp_bestFitMaxZoom);
					gp_forceBestFitMaxZoom = false;
				}
				google.maps.event.removeListener(zoomChangeBoundsListener);
	        });
		});
		
		//Event listener for right click
		google.maps.event.addListener(gp_map, 'rightclick', function(e) {
			gp_openRigthClickMenu(e); //Open the right click menu
		});

		//Event listener for left click to hide right click menu
		google.maps.event.addListener(gp_map, 'click', function(e) {
			gp_map.set('disableDoubleClickZoom', false); //Enable double click zoom again
			//Hide the context menu.
	 		jQuery("#mapContextMenu").hide();
	 	});

	 	//Event listener for bounds change to hide right click menu
		google.maps.event.addListener(gp_map, 'bounds_changed', function(e) {
			//Hide the context menu.
	 		jQuery("#mapContextMenu").hide();
	 	});

		//Add event listener to show/hide map controls on enter and exit of street view
	 	var thePanorama = gp_map.getStreetView();
		google.maps.event.addListener(thePanorama, 'visible_changed', function() {
		    if (thePanorama.getVisible()) {
		    	//Hide the map control tabs
		    	if( !$tabsBeforeStreetView || $tabsBeforeStreetView.length == 0 ){
		    		$tabsBeforeStreetView = jQuery(".mapControl:visible").hide();
		    	}
		    } else {
		        //Show the map control tabs
		        if($tabsBeforeStreetView){
		        	$tabsBeforeStreetView.show();
		        	$tabsBeforeStreetView = [];
				}
		    }
		});

		//Event listener for user drag
		google.maps.event.addListener(gp_map, 'dragend', function(e) {
			//User has moved the map, centerpoint address should change
			gp_mapManualMove();
	 	});

		//Create jquery event listner for map control panel so that if user moves map gp_centerPointKeepAddress is set to false, this is brittle has google may change markup
		jQuery("#mapDIV").on('click','div [title*="Pan"]',function(){
			gp_mapManualMove();
		});

		// Key Drag Zoom
		gp_map.enableKeyDragZoom({
			key: "shift", 
			boxStyle: {
				border: "medium dashed red",
				opacity: 0.80
			},
			paneStyle: {
				backgroundColor: "transparent",
				opacity: 0.00
			},
			visualEnabled: true,
			visualPosition: google.maps.ControlPosition.LEFT,
			visualPositionOffset: new google.maps.Size(35, 0),
			visualPositionIndex: null,
			visualSprite: "https://maps.gstatic.com/mapfiles/ftr/controls/dragzoom_btn.png",
			visualSize: new google.maps.Size(20, 20),
			visualTips: {
				off: "Turn on",
				on: "Turn off"
			}
		});

		//Event listner to call mapManualMove if someone use the shift drag zoom functionality
        var dz = gp_map.getDragZoomObject();
        google.maps.event.addListener(dz, 'dragend', function (bnds) {
        	gp_mapManualMove();
        });
		
		// My Location Control
		if (navigator.geolocation != null){
			var mlControl = jQuery('<div></div>').css({
														"margin": "0px 5px 10px 33px",
														"cursor": "pointer",
														"position": "relative"
													})
													.attr('title', 'Center the map on your current location')
													.append(
														jQuery('<div></div>')
																			.css({
																				"height": "22px",
																				"width": "22px",
																				"padding": "0",
																				"margin": "0",
																				"background-image": "url('https://maps.gstatic.com/mapfiles/my_location2.png')",
																				"background-position": "0 -21px"
																				})
													);
			mlControl[0].index=2;
			gp_map.controls[google.maps.ControlPosition.LEFT].push(mlControl[0]);
			google.maps.event.addDomListener(mlControl[0], 'click', function() {
				gp_centerZoomMyPosition();
				gp_mapManualMove();
			});
		}

		//Add autoload layers to the map
		gp_autoLoadLayers();
		
		gp_trackMapLoad();
		
	}
	
	// Set Size
	if (thisMC.setSize){
		//If height is null or auto, use auto height
		if(!thisMC.height || thisMC.height == 'auto'){
			thisMC.height = getAutoMapHeight();
		}
		jQuery("#mapDIV").width('100%');
		jQuery("#mapDIV").height (thisMC.height);
		google.maps.event.trigger(gp_map, 'resize');
	}
	
	// Set Center
	if (thisMC.setCenter){
		gp_map.setCenter(new google.maps.LatLng(thisMC.centerLat, thisMC.centerLng));
		gp_map.setZoom(thisMC.centerZoom);
	}
	
	// GeoLocation
	if (eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Use_Geolocation__c')){
		if (navigator.geolocation != null){
			if (thisMC.centerByGeoLocation){
    			navigator.geolocation.getCurrentPosition(function(position){
    				gp_map.setCenter(new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
			    	gp_map.setZoom(11);
				}, function() {
			      // continue on a failure
			    });
			}
		}
	}

	//After map is created set the max height of the route table, my locations table, and layers table
	setRouteTableMaxHeight();
	setMyLocationsTableMaxHeight();
	setDataSetTabMaxHeight();
	setLayersTableMaxHeight();
}

//Handles a poiCollections Request
function gp_poiCollections(jsAction){

	//Update the gp_dataSetSearches object 
	gp_updateDataSearchesObject(jsAction);
	
	var thisPOICollections = jsAction.poiCollections;
	
	// Quick loop through the POI Collections to determine if we should bestFit and/or remove shapes at the end
	gp_bestFitMaxZoom = 3;
	var toBestFit = false; // assume we are not doing bestFit
	var toRemoveAllShapes = true; // assume we are removing them
	if (thisPOICollections.length == 0){ toRemoveAllShapes = false; } // don't touch the points if there are no poiCollections
	jQuery.each(thisPOICollections, function(key, value) { 
		// Determine if we are removing shapes
		if(!value.removeAllShapes){ 
			toRemoveAllShapes = false;
		}
		
		// Determine if we are doing Best Fit
		if (value.bestFit) {
			toBestFit = true;
		}
		
		// Figure max bestFitMaxZoom
		if (value.bestFitMaxZoom > gp_bestFitMaxZoom){
			gp_bestFitMaxZoom = value.bestFitMaxZoom;
		}
	});
	

	// Removing markers and add back the center one if one exists
	if (toRemoveAllShapes){
		
		// Remove shapes and clear the global vars
		gp_cleanMapObjects();
		
		// Destroy the jQuery Data Tables 
		gp_destroyDataTables('gp_dataTables'); 

		//Reset object that keeps track of selected records
		gp_selectedRecords = {};
		
		// Add the center one back
		if (gp_masterMarker != null){
			
			gp_masterMarker.setMap(gp_map); // Add back onto the map
			gp_bounds.extend(gp_masterMarker.getPosition()); // Extend the bounds object so we can do bestFit later
				
			// Add them using the uniqueId as an Index so we can interact with them outside the map
			if(gp_masterMarker.uniqueID != null){ 
				gp_markers[gp_masterMarker.uniqueID] = gp_masterMarker;
			}
		}
	}
	
	// Loop through each poiCollection
	jQuery.each(thisPOICollections, function(key, value) {
		
		thisPOIC = value;
		thisPOIC.searchType = jsAction.searchType;
		thisPOIC.sfdcObject = '';
		thisPOIC.writeBackEnabled = jsAction.writeBackEnabled;
		thisPOIC.writeBackLookupObject = jsAction.writeBackLookupObject;
		thisPOIC.writeBackButtonText = jsAction.writeBackButtonText;
		
		// Determine whether we should create the table
		var createTable = thisPOIC.collectionName != gp_centerPOICollectionName;
		
		if(createTable){
			jQuery('#gp_dataTablesNoData').hide(); // Hide the No Data message
			gp_newDataTableStructure('gp_dataTables', thisPOIC); // Add new jQuery Data Table structure
			var tableCols = gp_defineDataTableColumns(thisPOIC); // Prepare the columns array for use in creating the data table
		}
		
		// Loop over data and add POIS / rows to table
		var tableData = new Array();
		var tmpMarkersArray = [];
		if(typeof(value.POIs) != "undefined"){
			if(value.POIs != null){
				for(var i = 0; i < value.POIs.length; i++){
					
					thisPOI = gp_finishPOIObject(value.POIs[i]); //TODO perf 2500ms
					thisPOI.poicCollectionName = thisPOIC.collectionName;
					thisPOIC.sfdcObject = thisPOI.sfdcObject;
					
					// Archive off the centerPOI
					if (thisPOI.uniqueId == gp_centerPOICollectionName) { gp_centerPOI = thisPOI; }
							
					gp_handlePOI(thisPOIC, thisPOI); //TODO perf 375ms, adding marker, not much can be done
					
					// Add a row of data to the data table array
					if(createTable){ tableData.push(gp_defineDataTableRow(thisPOIC, thisPOI)); }
					
					thisPOI = null;
				}// end of loop through each poi
			}
		}
		
		// create circle overlay
		if(	thisPOIC.searchType == 'nearby' 
			&& typeof(thisPOIC.searchNearbyRange) != "undefined" 
			&& typeof(thisPOIC.searchNearbyLat) != "undefined" 
			&& typeof(thisPOIC.searchNearbyLng) != "undefined"
			&& jsAction.searchNearbyShowOverlay){
		    
				var radius = gp_milesToMeters(thisPOIC.searchNearbyRange);
				if(thisPOIC.distanceUnits=='kilometers' || thisPOIC.distanceUnits=='km' || thisPOIC.distanceUnits=='k'){
					radius = thisPOIC.searchNearbyRange * 1000;
				}
				
				var cirOptions = {
		          clickable:false, //Disable clicks so right click event on map below opens context menu
		          strokeColor: "#B00303", //'#B00303'; '#1797c0';
		          strokeOpacity: 0.5,
		          strokeWeight: 2,
		          fillColor: "#EFFF79", //'#EFFF79'; '#1797c0';
		          fillOpacity: 0.10,
		          map: gp_map,
		          center: new google.maps.LatLng(thisPOIC.searchNearbyLat, thisPOIC.searchNearbyLng),
		          radius: radius
		        };
			    var circle = new google.maps.Circle(cirOptions);
			    gp_cirOverlays[thisPOIC.collectionName + '_overlay'] = circle;
			    
			    gp_bounds.union(circle.getBounds());
		    
		}
	    
		// Initialize the Data Table
		if(createTable){
			//Delay the creation of the table slightly
			setTimeout(function(){ 
				//value is the POI collection in the larger jQuery loop, need to use this due do the way var are stored and used in timeout functions
				gp_initDataTable(value, tableCols, tableData)  

				// Calculate Drive Times
				if (jsAction.searchNearbyDriveCalc){
					gp_calcDriveTimes(value.collectionName, value.distanceUnits);
				}
			}, 50);
		}
		
	}); // end of loop through each poiCollection 
	
	//If there are shapes on the map make sure they are included in the bounds calculation so the map zoom contains entire shape
    for(key in polygonObjects){
    	var bounds = polygonObjects[key].getBounds();
    	gp_bounds.extend( new google.maps.LatLng(bounds.getNorthEast().lat(), bounds.getNorthEast().lng()) );
    	gp_bounds.extend( new google.maps.LatLng(bounds.getSouthWest().lat(), bounds.getSouthWest().lng()) );
    }

	// Best Fit
	if (toBestFit) {
		gp_forceBestFitMaxZoom = true;
		gp_centerZoom();
	}

	//Build the list actions
	buildListActions(); //map.actions.js
	
}

//Take an object as input and process the POI onto the map
function gp_handlePOI(thisPOIC, thisPOI){
	
	if(!thisPOI.isBlankLat && !thisPOI.isBlankLng){
		
		// Make Lat Lon Object
		var g_latlon = new google.maps.LatLng(thisPOI.latDisplay, thisPOI.lngDisplay);
		
		// Extend the bounds object so we can do bestFit later
		gp_bounds.extend(g_latlon);
		
		// Build the InfoContentHTML
		var tmpInfoContentHTML = '';
		tmpInfoContentHTML += '<div style="font-size: 8pt;" class="poiTooltip" >';
		tmpInfoContentHTML += '<b style="font-size: 9pt; text-decoration: underline;">' + thisPOI.title + '</b><br/>';
		if(thisPOI.title2 != ''){
			tmpInfoContentHTML += '<b style="font-size: 9pt;">' + thisPOI.title2 + '</b><br/>';
		}
		tmpInfoContentHTML += thisPOI.formattedAddr;
		if (thisPOI.distanceInfo){
			tmpInfoContentHTML += thisPOI.distanceInfo;
		}
		if (thisPOI.geocodeQuality){
			tmpInfoContentHTML += '<br/><b>Geocode Quality</b>: ' + thisPOI.geocodeQuality;
		}
		
		if(thisPOI.additionalFields){
			tmpInfoContentHTML += '<hr/>';
			jQuery.each(thisPOI.additionalFields, function(key, value) { 
				tmpInfoContentHTML += '<b>' + value.label + '</b>: ' + gp_formatOutputField(value.datatype,value.value,thisPOI.recordId,thisPOI.title) + '<br/>';
			});
		}
		
		//POI Buttons
		tmpInfoContentHTML += '<div class="poiTooltipButtons">';
		tmpInfoContentHTML += 		buildPOIActions(thisPOIC,thisPOI,'button'); //map.actions.js
		tmpInfoContentHTML += '</div>';
		// end POI Buttons
		
		//Map Actions
		tmpInfoContentHTML += '<div style="margin: 5px 0; padding: 5px; background-color: #efebe2; line-height:1.5em;"><span style="font-size: 10pt;"><b>Map Actions:</b></span>';
		tmpInfoContentHTML += '<br/><span style="text-decoration:underline; cursor:pointer;" onclick="gp_zoomToStreet(' + thisPOI.latDisplay + ',' + thisPOI.lngDisplay + ',16);">Zoom &amp; Center</span>';
		tmpInfoContentHTML += '&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_enableStreetView(' + thisPOI.lat + ',' + thisPOI.lng + ')">Street View</span>';
		tmpInfoContentHTML += '&nbsp;&nbsp;<a href="http://maps.google.com?f=q&q=' + escape(thisPOI.street) + ',' + escape(thisPOI.city) + ',' + escape(thisPOI.state) + ' ' + escape(thisPOI.postalCode) + ' ' + escape(thisPOI.countryISO) + '@' + thisPOI.lat + ',' + thisPOI.lng + '(' + escape(thisPOI.title) + ')" target="_blank">View on Google Maps</a>';
		tmpInfoContentHTML += '</div>';
		
		//Record Actions
		var actionsHTML = buildPOIActions(thisPOIC,thisPOI,'link');
		if(actionsHTML){
			tmpInfoContentHTML += '<div class="poiTooltipActions"><span style="font-size: 10pt;"><b>Record Actions:</b></span><br/>';
			tmpInfoContentHTML += 		actionsHTML;
			tmpInfoContentHTML += '</div>';
		}
		
		//tmpInfoContentHTML += '<hr/><select id="contextShapeType' + thisPOI.uniqueId + '"><option value="Postal Code">Postal Code</option><option value="Municipality">Municipality</option><option value="Time Zone">Time Zone</option></select>';
		//tmpInfoContentHTML += '<input class="btn" onclick="var shapeType = jQuery(\'#contextShapeType' + thisPOI.uniqueId + '\').val(); gp_SGContextSearch(' + thisPOI.lat + ',' + thisPOI.lng + ',shapeType); return false;" value="Add Context Layer" type="button" />';
		
		if (thisPOIC.writeBackEnabled){
			if (thisPOI.sfdcObject == thisPOIC.writeBackLookupObject){
				tmpInfoContentHTML += '<hr/><input class="btn" onclick="geopointeAjaxStart(\'body\',\'Updating Originating Record...\'); gp_writeBackSelection(\'' + thisPOI.recordId + '\'); return false;" value="' + thisPOIC.writeBackButtonText + '" type="button" />';
			}
		}
		
		tmpInfoContentHTML += '</div>';
			
		var hoverText = thisPOI.title;
		if (thisPOI.title2 != ''){
			hoverText = '<strong>'+ thisPOI.title + '</strong><br/>' + thisPOI.title2;
		}
		
		// Create this GMarker
		var g_marker = gp_createMarker(g_latlon, hoverText, tmpInfoContentHTML, thisPOI.mapIconURL, thisPOI.uniqueId); //TODO perf 300ms
		
		//Set the collectionName property on the marker object so we can keep track of what markers belong to each data set search
		g_marker.collectionName = thisPOI.poicCollectionName;

		// Add them to the main object using the uniqueId as an Index so we can interact with them outside the map
		if(thisPOI.uniqueId != ''){
			gp_markers[thisPOI.uniqueId] = g_marker;
		}
		
		// Save off the centerPOI marker
		if (thisPOI.poicCollectionName == gp_centerPOICollectionName){
			gp_masterMarker = g_marker;
		}
		
		// Add the Marker to the map
		g_marker.setMap(gp_map); 
	}
	
	return null;
	
}

//Creates and returns a map marker
function gp_createMarker(latlng,title,html,image,uid,placeInfo) {
	
	// Create traditional marker
	var marker = new google.maps.Marker({
	      position: latlng, 
	      map: gp_map,
	      icon: image,
	      flat: true
	});  
	
	// Add custom properties to it
	marker.tooltip = '<div class="nowrap">'+title+'</div>';
	marker.tooltipDetail = '';
	if(html){
		marker.tooltipDetail = html.substring(0,html.indexOf('<div class="poiTooltipButtons">'));
	}            
	marker.infoWindowHTML = html;
	marker.uniqueID = uid;
	
	// Marker Click Event
	if(typeof(placeInfo)=="undefined"){
		google.maps.event.addListener(marker, 'click', function() {
			
			//If we are in record selection mode perform special handling from record clicks
			if(gp_inRecordSelectionMode && marker.uniqueID != 'gp_mapCenterPoi' && marker.uniqueID != 'centerPOI'){
				gp_toggleRecordSelection(marker.uniqueID);
			}else{
				gp_openPoiInfoMarker(marker.uniqueID);
			}
			gp_tooltip.hide();
		});
	} else {
		google.maps.event.addListener(marker, 'click', function() {
			gp_placesInfoWindowHandler(placeInfo,marker);
		});
	}
	
	// Marker Mouseover Event 
	google.maps.event.addListener(marker,"mouseover", function() {
		if(gp_inRecordSelectionMode && marker.uniqueID != 'gp_mapCenterPoi'){
			gp_tooltip.setContent(marker.tooltipDetail);
		}else{
			gp_tooltip.setContent(marker.tooltip);
		}
		gp_tooltip.show();
		gp_tooltip.open(gp_map, marker);
	});
	
	// Marker Mouseout Event
	google.maps.event.addListener(marker,"mouseout", function() {
		gp_tooltip.hide();
	}); 
	return marker;
}

//Toggle record selection, add checkmark to map, update checkbox in table
function gp_toggleRecordSelection(uniqueId){
	
	//Set apply to picklist to selected records
	jQuery("#applyActionTo").val('selectedRecords');

	//Check to see if the record is already selected
	if(!gp_selectedRecords[uniqueId]){
		gp_selectedRecords[uniqueId] = true;

		gp_markers[uniqueId].selectedMarker = new google.maps.Marker({
			position: gp_markers[uniqueId].getPosition(), 
			map: gp_map,
			icon: {
                anchor: new google.maps.Point(0,17),
                scaledSize: new google.maps.Size(18,18),
                size: new google.maps.Size(18,18),
                url: redCheckIconURL,
                zIndex: 20000
            },
			flat: false
		});  

	}else{
		//Set selected flag as false for the record
		gp_selectedRecords[uniqueId] = false;
		
		//Remove the selected marker from the map
		gp_markers[uniqueId].selectedMarker.setMap(null);
		gp_markers[uniqueId].selectedMarker = null;
	}

	updateDataTableSelectedProp(uniqueId);
}

//Remove a route from the map
function gp_removeRouteFromMap(){
	if(gp_dir){
		gp_dir.setMap(null);
		gp_dir.setPanel(null);
	}
}

//Add the existing route back to the map
function gp_restoreRouteOnMap(){
	if(gp_dir){
		gp_dir.setMap(gp_map);
	}
}

// Handles a Route Request
function gp_routeRequest(jsAction){
	
	var thisRR = jsAction.routeRequest;
	
	// change null to '' for all properties
	jQuery.each(thisRR, function(key, value) { 
		if (value == null){ thisRR[key] = '';}
	});
	
	thisRR.draggable = true;
	thisRR.timeType = 1;
	thisRR.locationsJS = gp_getlocationsJS();
	thisRR.locationsDisplayJS = gp_getlocationsDisplayJS();
	thisRR.latLngJS = gp_getLatLngJS();
	
	if (thisRR.runRoute){
		
		// Clear the route from the map
		if (typeof(gp_dir) != 'undefined'){
			gp_dir.setMap(null);
			gp_dir.setPanel(null);
		}
		
		// Create a Directions Renderer object
		gp_dir = new google.maps.DirectionsRenderer({suppressInfoWindows: false});
		gp_dir.setMap(gp_map);
		
		// Directions Service
		var gp_dirService = new google.maps.DirectionsService();
		
		if (thisRR.latLngJS.length > 1) {
			
			jQuery("#routeNarrativeDIV").html('');
			
			// Directions Request Options
			var opts = {};
				opts.travelMode = google.maps.TravelMode.DRIVING;
		        if (thisRR.routeType == 'pedestrian') {
		        	opts.travelMode = google.maps.TravelMode.WALKING;
		        } else if (thisRR.routeType == 'bicycle') {
		        	opts.travelMode = google.maps.TravelMode.BICYCLING;
		        } else if (thisRR.routeType == 'multimodal') {
		        	opts.travelMode = google.maps.TravelMode.TRANSIT;
		        }
		        opts.avoidHighways = thisRR.avoidHighways;
		        opts.avoidTolls = thisRR.avoidTolls;
		        opts.provideRouteAlternatives = false;
		        opts.optimizeWaypoints = thisRR.optimize;
		        opts.unitSystem = google.maps.UnitSystem.IMPERIAL;
		        if (thisRR.units == 'k'){ opts.unitSystem = google.maps.UnitSystem.METRIC; }
		        
				opts.origin = new google.maps.LatLng(thisRR.latLngJS[0].latLng.lat, thisRR.latLngJS[0].latLng.lng);
				opts.destination = new google.maps.LatLng(thisRR.latLngJS[thisRR.latLngJS.length - 1].latLng.lat, thisRR.latLngJS[thisRR.latLngJS.length - 1].latLng.lng);
				if (thisRR.latLngJS.length > 2) {
					var ways = [];
					for(var i = 1; i < thisRR.latLngJS.length - 1; i++) {
						ways.push({location: new google.maps.LatLng(thisRR.latLngJS[i].latLng.lat, thisRR.latLngJS[i].latLng.lng), stopover:true});
					}
					opts.waypoints = ways;
				}
				
			gp_dirService.route(opts, function(result,status){
				if (status == google.maps.DirectionsStatus.OK) {
					gp_routeRequestLocs = thisRR.locationsJS;
					gp_routeResultsData = result;
					gp_dir.setDirections(result);
					setTimeout("gp_dir.setDirections(gp_routeResultsData)", 34); // again b/c Google is being weird on the zoom
					gp_displayRouteNarrative(thisRR, result); // write the results out

					//Track the route request
					thisRR.status = 'Success';
					gp_trackRoute(thisRR);

				}else{
					//Error messaage
					jQuery.jGrowl('Unable to build route. Message: ' + status);

					//Track the route request
					thisRR.status = status;
					gp_trackRoute(thisRR);
				}
			});
		}
	}
}

//Custom direction panel (from http://econym.org.uk/gmap/steps.htm) modified for v3 API
function gp_displayRouteNarrative(thisRR, data){
	
	var html = "";
	var htmlPDF = "";
	var dtwaypoints=[];
	
	// Put results into a global variable
	var thisRoute = data.routes[0];
	
	// Determine the route order
	var locationsSequence = []
	locationsSequence.push(0); // push the origin into the array
	if (typeof(thisRoute.waypoint_order) != 'undefined'){
		for (var i=0; i < thisRoute.waypoint_order.length; i++) {
			locationsSequence.push(thisRoute.waypoint_order[i]+1); // waypoint order into the array
		}
	}
	locationsSequence.push(locationsSequence.length); // push the destination into the array
	
	// ===== local functions =====

	function staticMap(){
		// added to front of PDF
		var staticMapURL = 'https://maps.googleapis.com/maps/api/staticmap';
		staticMapURL += '?size=700x500';
		staticMapURL += '&maptype=roadmap';
		staticMapURL += '&format=png';
		staticMapURL += '&sensor=false';
		staticMapURL += '&path=enc:' + thisRoute.overview_polyline.points;
		
		var abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		for (var i=0; i < thisRoute.legs.length; i++) {
			staticMapURL += '&markers=color:green|label:' + abc.substring(i,i+1) + '|' + thisRoute.legs[i].start_location.lat() + ',' + thisRoute.legs[i].start_location.lng();
		}
		staticMapURL += '&markers=color:green|label:' + abc.substring(thisRoute.legs.length,thisRoute.legs.length+1) + '|' + thisRoute.legs[thisRoute.legs.length-1].end_location.lat() + ',' + thisRoute.legs[thisRoute.legs.length - 1].end_location.lng();
		
		htmlPDF =	'<table class="dirImageTable" border="0"><tr><td><img src="' + staticMapURL + '" alt="Route Overview Map"/></td></tr></table>' + htmlPDF;
	}
	
	function datatable(){
		// added to front of PDF
		var tmp = '<div class="dirSection">LOCATION SUMMARY</div>';
		tmp += 	'<table class="waySummary">' + 
						'<tr>' + 
						'<th width: 20px;">&nbsp;</td>' + 
						'<th style="vertical-align: middle;">Location Name</td>' +
						'<th style="vertical-align: middle;">Street</td>' +
						'<th style="vertical-align: middle;">City</td>' +
						'<th style="vertical-align: middle;">State / Province</td>' +
						'<th style="vertical-align: middle;">Postal Code</td>' +
						'<th style="vertical-align: middle;">Country</td>' +
						'</tr>';
		for (var i=0; i < dtwaypoints.length; i++) {
			tmp += dtwaypoints[i];
		}
		tmp += '</table>';
		htmlPDF = tmp + htmlPDF;
	}
	
	function warnings(){
		if (thisRoute.warnings){
			for (i = 0; i < thisRoute.warnings.length; i++) {
				var tmp = '<div class="dirWarnings"><b>' + thisRoute.warnings[i] + '</b></div><br/>';
				html += tmp;
				htmlPDF +=	tmp;
			}
		}
	}
	
	function summary(){ 
		var dist = 0; 
		var dur = 0; 
		var unit = '';
		for (var i=0; i < thisRoute.legs.length; i++) {
			dist += thisRoute.legs[i].distance.value; // in meters
			dur += thisRoute.legs[i].duration.value; // in seconds
		}
		if (thisRR.units == 'k'){ 
			unit = 'km';
			dist = dist/1000;
		} else {
			unit = 'mi';
			dist = dist / 1609.344;
		}

		var durationHours = Math.floor(dur/3600);
		var durationMinutes = Math.round( (dur/60)%60 );

		var minLabel = 'mins';
		if(durationMinutes == 1){
			minLabel = 'min';
		}

		var durationText = ' (about '+durationHours;
		if(durationHours == 0){
			durationText = ' (about '+durationMinutes+' '+minLabel+')';
		}else if(durationHours == 1){
			durationText += ' hour ' + durationMinutes + ' '+minLabel+')' 
		}else{
			durationText += ' hours ' + durationMinutes + ' '+minLabel+')' 
		}
		
		var tmp = '<div class="dirTotalTimeGOOG">' + 
				'<b style="padding: 0px 10px;">TOTAL DISTANCE AND TIME:</b> ' + Math.round(dist*100)/100 + ' ' + unit + durationText + 
				'</div>';
		
		html += tmp;
		htmlPDF += tmp;
		
	}
	
	// waypoint banner
	function waypoint(img, address, dist) {
		var tmp = 	'<table class="dirLegSummaryGOOG"><tr>' + 
					'<td style="padding: 4px 15px 4px 5px; vertical-align: middle; width: 20px;"><img src="' +img+ '"></td>' + 
					'<td style="vertical-align: middle; width: 760px;">' + address + '</td>' + 
					'<td style="vertical-align: middle; text-align: right; width: 200px;">' + dist + '</td>'
					'</tr></table>';
		html += tmp;
		htmlPDF += tmp;
		
	}
	
	// waypoints for data table
	function waypointInTable(img,thisLD){
		var tmp = 	'<tr>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); padding: 4px 15px 4px 5px; vertical-align: middle; width: 15px;"><img width="75%" height="75%" src="' +img+ '"></td>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 150px;">' + thisLD.name + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 150px;">' + thisLD.street + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 80px;">' + thisLD.city + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 50px;">' + thisLD.state + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 60px;">' + thisLD.postalCode + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 80px;">' + thisLD.country + '&nbsp;</td>' +
					'</tr>';
		dtwaypoints.push(tmp);
	}

	// step detail
	function detail(num, description, step) {
		var tmp =	'<table class="dirManeuverGOOG"><tr>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); margin: 0px; padding: 0.3em 5px; vertical-align: top; text-align: right; width:20px;">' + num + '</td>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); margin: 0px; padding: 0.3em 5px; vertical-align: top; width: 760px;">' + description + '</td>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); margin: 0px; padding: 0.3em 5px 0.3em 0.5em; vertical-align: top; text-align: right; width:200px">' + step.distance.text + ' ('+ step.duration.text +')</td>' + 
					'</tr></table>';
		html += tmp;
		htmlPDF += tmp;
	}

	// Copyright tag
	function copyright(text) {
		var tmp = '<div style="font-size: 0.86em;">' + text + "</div>";

		html += tmp;
		htmlPDF += tmp;
	}
	
	// ===== start output =====
	
	// Warning messages
	warnings();
	
	htmlPDF += '<div style="margin: 20px 0 0 0;" class="dirSection">DETAILED DIRECTIONS</div>';
	
	// Summary at the top of the route
	summary();
	
	// Read through the GRoutes and GSteps
	var abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	for (var i=0; i < thisRoute.legs.length; i++) {

		var thisLD = thisRR.locationsDisplayJS[locationsSequence[i]];
		var nextLD = thisRR.locationsDisplayJS[locationsSequence[i+1]];
		
		var thisLL = thisRR.latLngJS[locationsSequence[i]].latLng;
		var nextLL = thisRR.latLngJS[locationsSequence[i+1]].latLng;
		
		//var img = "https://maps.gstatic.com/intl/en_us/mapfiles/icon_green" + abc.substring(i,i+1) + ".png";
		var img = "https://maps.google.com/mapfiles/marker_green" + abc.substring(i,i+1) + ".png"
		
		var leg = thisRoute.legs[i];

		// Assess geocode quality
		var poorGCImage = '<img src="/resource/' + gp_orgSettings.folderPrefix + 'images/warning12.png" alt="Poor Geocode Quality" />';
		var goodGCImage = '<img src="/resource/' + gp_orgSettings.folderPrefix + 'images/confirm12.png" alt="Good Geocode Quality" />';
		var fromGC = thisLD.gc;
		var fromGCImage = poorGCImage;
		var toGC = nextLD.gc;
		var toGCImage = poorGCImage;
		if (fromGC == 'POINT' || fromGC == 'ADDRESS' || fromGC == 'STREET' || fromGC == 'INTERSECTION' || fromGC == 'CUSTOM'){
			fromGCImage = goodGCImage;
		}
		if (toGC == 'POINT' || toGC == 'ADDRESS' || toGC == 'STREET' || toGC == 'INTERSECTION' || toGC == 'CUSTOM'){
			toGCImage = goodGCImage;
		}
		
		// To/From Waypoint info
		var fromAddr = thisLD.name + ' @ ' + thisLD.street + ' ' + thisLD.city + ', ' + thisLD.state + ' ' + thisLD.postalCode + ' ' + thisLD.country;
		if (fromGC == 'CUSTOM'){
			fromAddr = thisLD.name + ' @ ' + thisLL.lat + ' , ' + thisLL.lng;
		}
		fromAddr += '<i>&nbsp;(Geocode Quality: ' + fromGCImage + '&nbsp;' + fromGC + ')</i><br/>';
		
		var toAddr = nextLD.name + ' @ ' + nextLD.street + ' ' + nextLD.city + ', ' + nextLD.state + ' ' + nextLD.postalCode + ' ' + nextLD.country;
		if (toGC == 'CUSTOM'){
			toAddr = nextLD.name + ' @ ' + nextLL.lat + ' , ' + nextLL.lng;
		}
		toAddr += '<i>&nbsp;(Geocode Quality: ' + toGCImage + '&nbsp;' + toGC + ')</i><br/>';
		
		// Distance summary
		var distSum = leg.distance.text + ' ('+leg.duration.text +')';
		
		waypoint(img, fromAddr, distSum);
		
		waypointInTable(img, thisLD);
		
		for (var j=0; j< leg.steps.length; j++) {
			
			var step = leg.steps[j];
			
			// detail lines for each step
			detail(j+1, step.instructions, step);
		}
		
		
		if (i == thisRoute.legs.length-1){
			// the final destination waypoint
			var leg = thisRoute.legs[thisRoute.legs.length-1];
			var img = "https://maps.google.com/mapfiles/marker_green" + abc.substring(thisRoute.legs.length,thisRoute.legs.length+1) + ".png"
			waypoint(img, toAddr, '');
			waypointInTable(img, nextLD);
		}
	}
			 
	// the copyright text
	copyright(thisRoute.copyrights);

	// Add data table to the top of the PDF
	datatable();
	
	// Add static map to the top of the PDF
	staticMap();
	
	// Reorder the location list if we did an optimized route
	if(thisRR.optimize){
		gp_reorderRouteLocations(locationsSequence);
	}
	
	// populate the hidden input with the html

	//Create a route tab under the map if it doesn't already exisit
	gp_createRouteTab(); //GeopointeJS

	gp_UIElem.hidden_htmlDirections.value = htmlPDF;
	
	jQuery("#routeNarrativeDIV").html(html);

	//Reset floating headers as width of table content may have changed
	createFloatingTableHeaders('#gp_dataTableRoute','#routeFloatingHeaders');
	
	//Reset tab offsets as height of route tab content may have changed
	resetMapControlOffset('#routePanel'); 
}

// Removes the route and adds the markers back onto the map
function gp_resetCenterPOIContext(div){

	// Remove the route
	if (typeof(gp_dir) != 'undefined'){
		gp_dir.setMap(null);
		gp_dir.setPanel(null);
	}
	
	// Add back the markers onto the map
	for(var i in gp_markers) {
		gp_markers[i].setMap(gp_map);
	}
	gp_infoWindow.close();
	gp_tooltip.hide();
	for(var i in gp_cirOverlays) {
		gp_cirOverlays[i].setMap(gp_map);
	}
	for(var i in gp_kmlOverlays) {
		gp_kmlOverlays[i].setMap(gp_map);
	}
	
	// Best Fit
	gp_centerZoom(16);
	
	// Reload the Color By drop-down
	gp_UIElem.hidden_colorMarkersBy.value='';
	
	jQuery( "#theTabPanel" ).tabs("select",gp_JQTabs.mapDataSets);
	
	geopointeAjaxEnd();
}

//Runs a Search Nearby passing the center of the map along with the query
function gp_searchNearbyRecordsWrapper(isRemote,options){

	geopointeAjaxStart('body','Performing a Radial Search...'); 
	
	// Clear the hidden data so we don't keep sending it to server
	gp_clearHiddenFields();
 	
	// Get Map Center
	var centerLat = gp_getCenterObject().lat;
	var centerLng = gp_getCenterObject().lng;

	//If options where provided with lat lng use these
	if(options && options.radialCenterLat && options.radialCenterLng){
		centerLat = options.radialCenterLat;
		centerLng = options.radialCenterLng;
	}

	// If we are in Search mode, add a POI to the map to act as the center
	if (loadWithCenterPOI == false || rightClickRepositionOccured == true){

		gp_centerPOI = gp_getCenterObject();
		
		// Removing the center poi if it exists on the map
		if(gp_masterMarker != null){ 
			gp_removeMarkerMap(gp_masterMarker.uniqueID);
			gp_masterMarker = null;
		}
		
		var g_latlon = new google.maps.LatLng(centerLat, centerLng);
		gp_bounds.extend(g_latlon);
		
		tmpInfoContentHTML = '<span id="latLng"><b>Latitude: </b>'+centerLat.toFixed(4)+'<br/><b>Longitude: </b>'+centerLng.toFixed(4)+'<br/></span>'+ //hide after Geocode
		'<span id="address"/>'+ //Show after geocode

		'<div style="margin: 5px 0; padding: 5px; background-color: #efebe2; line-height:1.5em;">'+
			'<span style="font-size: 10pt;"><b>Map Actions:</b></span><br/>'+
			'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_searchRadialRemote(' + centerLat + ',' + centerLng + ');">Radial Search</span>'+
			'&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_zoomToStreet(' + centerLat + ',' + centerLng + ',16);">Zoom &amp; Center</span><br/>'+
			'<span id="routesAndLocations" style="display:none;">'+ // show after geocode 
				'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_addToRouteSearchOrCenterPOI(gp_centerPOI,\'center\');">Add To Route</span>'+
				'&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_addToMyLocations(gp_radialAddress);">Save To My Locations</span><br/>'+
			'</span>'+ 
			'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_enableStreetView(' + centerLat + ',' + centerLng + ')">Street View</span>'+
			'&nbsp;&nbsp;<a href="http://maps.google.com?q='+ centerLat +','+ centerLng +'" target="_blank">View on Google Maps</a>';
		'</div>';

		//If this radial search was launched from a my location use that HTML
		if(options.keepCenterAddress || gp_centerPointKeepAddress){
			tmpInfoContentHTML = gp_searchPOI.markerHtml;		
		}

		var g_marker = gp_createMarker(	g_latlon
										, '<b>Center of Map for Last Radial Search</b>', tmpInfoContentHTML
										, '/resource/' + gp_orgSettings.folderPrefix + 'images/center_pin2.png'
										, 'gp_mapCenterPoi');
		
		gp_markers[g_marker.uniqueID] = g_marker;
		gp_masterMarker = g_marker;
		g_marker.setMap(gp_map);
		
		//Update search center title
		if(options.keepCenterAddress || gp_centerPointKeepAddress){
			var centerTitle = '<span class="centerContextTitle">Search Center:</span> ' + gp_searchAddress.singleLineAddress;	

			//Update the title
			jQuery("#centerContextTitleOutput").html(centerTitle);	
		}else{
			//Do reverse geocode and attempt to update address in the marker bubble
			var latlng = new google.maps.LatLng(centerLat,centerLng)

			var centerTitle = '<span class="centerContextTitle">Search Center:</span> ';

			//Do the reverse geocode to get the address
			var geocoder = new google.maps.Geocoder();
			geocoder.geocode({'latLng': latlng}, function(results, status) {

				if (status == google.maps.GeocoderStatus.OK) {
					centerTitle += ' ' + results[0].formatted_address;

					//Parse google geocode and store result in var, store in case user wants to add to their saved locations
					gp_radialAddress = gp_parseGoogleGeocode(results[0]);

					//Update the gp_CenterPOI object
					gp_centerPOI.lat = results[0].geometry.location.lat();
					gp_centerPOI.lng = results[0].geometry.location.lng();
					gp_centerPOI.countryISO = gp_radialAddress.country;
					gp_centerPOI.title = gp_radialAddress.title;
					gp_centerPOI.street = gp_radialAddress.street;
					gp_centerPOI.city = gp_radialAddress.city;
					gp_centerPOI.state = gp_radialAddress.state;
					gp_centerPOI.postalCode = gp_radialAddress.postalCode;
					gp_centerPOI.country = gp_radialAddress.country;
					gp_centerPOI.geocodeQuality = 'CUSTOM';
					gp_centerPOI.usesCustomerGeocode = '';
					gp_centerPOI.recordId = '';
					
					//Update the HTML for the gp_masterMarker
					if(gp_masterMarker.infoWindowHTML){
						//Show the Add To Route and Save to Locations links
						gp_masterMarker.infoWindowHTML = gp_masterMarker.infoWindowHTML.replace('<span id="routesAndLocations" style="display:none;">','<span id="routesAndLocations">');

						//Update the address, first hide the defaul address
						gp_masterMarker.infoWindowHTML = gp_masterMarker.infoWindowHTML.replace('<span id="latLng">','<span id="latLng" style="display:none;">');
						gp_masterMarker.infoWindowHTML = gp_masterMarker.infoWindowHTML.replace('<span id="address"/>','<span id="address">'+gp_radialAddress.fullAddress+'</span>');
					}
				}else{
					centerTitle += ' The map\'s center will be used as the centerpoint for the radial search.';
				}

				//Update the title
				jQuery("#centerContextTitleOutput").html(centerTitle);

				//Show the back to record link, this will only have been rendered if page loaded from a record
				jQuery("#backTorRecordFullName").show();

				//Called to reset the ActionFunction bug		
				gp_emptyActionFunction(); 
			});
		}	
	}
	
	gp_trackRadialSearch();
	
	if(isRemote != true){
		gp_searchNearbyRecords(centerLat,centerLng);// Action function that does the search
	}
	
}

function gp_removeCenterMarker(){
	// Removing the center poi if it exists on the map
	if(gp_masterMarker != null){ 
		gp_removeMarkerMap(gp_masterMarker.uniqueID);
		gp_masterMarker = null;
		jQuery("#centerContextTitleOutput").html('<span class="centerContextTitle">Search Center:</span> The map\'s center will be used as the centerpoint for the radial search.');
	}
}

//Resizes the map to be the width of the div
function gp_resetMapWidth(){
	google.maps.event.trigger(gp_map, 'resize');

	//Resent legend max width
	setLegendMaxWidthHeight();
}

function gp_setMapHeight(height){
	if(height == 'auto'){
		height = getAutoMapHeight();
	}
	jQuery("#mapDIV").width('100%');
	jQuery("#mapDIV").height (height);
	google.maps.event.trigger(gp_map, 'resize');
	setRouteTableMaxHeight();
	setMyLocationsTableMaxHeight();
	setDataSetTabMaxHeight();
	setLayersTableMaxHeight();
}

//Called from a link inside a POI to zoom down to that location
function gp_zoomToStreet(lat, lon, zoom){
	gp_map.setCenter(new google.maps.LatLng(lat, lon));
	gp_map.setZoom(zoom);
}

function gp_getZoomLevel(){
	return gp_map.getZoom();
}

function gp_centerZoomMyPosition(){
	if (navigator.geolocation != null){
		navigator.geolocation.getCurrentPosition(function(position){
			gp_map.setCenter(new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
	    	gp_map.setZoom(14);
		}, function() {
			jQuery.jGrowl('Your browser failed to determine your current location');
	    });
	} else {
		jQuery.jGrowl('Your browser does not support determination of your current location');
	}
}

function gp_centerRightClick(){
	//Recenter map
	gp_map.panTo(new google.maps.LatLng(rightClickLatLng.lat, rightClickLatLng.lng));
	gp_trackRightClick('Center');
}

function gp_bestFitRightClick(){
	gp_centerZoom();
	gp_trackRightClick('Show All Mapped Points');
}

function gp_streetViewRightClick(){
	gp_enableStreetView(rightClickLatLng.lat, rightClickLatLng.lng);
	gp_trackRightClick('Street View');
}

function gp_centerZoomRightClick(){
	gp_centerRightClick();

	//Based on current zoom level zoom in.
	var zoom = gp_getZoomLevel();
	var newZoom = 14; //Default
	if(zoom == 0){
		newZoom = 3;
	}else if(zoom == 1){
		newZoom = 5;
	}else if(zoom == 2){
		newZoom = 6;
	}else if(zoom == 3){
		newZoom = 7;
	}else if(zoom == 4){
		newZoom = 7;
	}else if(zoom == 5){
		newZoom = 9;
	}else if(zoom == 6){
		newZoom = 11;
	}else if(zoom == 7){
		newZoom = 11;
	}else if(zoom == 8){
		newZoom = 12;
	}else if(zoom == 9){
		newZoom = 13;
	}else if(zoom == 10){
		newZoom = 14;
	}else if(zoom == 11){
		newZoom = 15;
	}else if(zoom == 12){
		newZoom = 15;
	}else if(zoom == 13){
		newZoom = 16;
	}else if(zoom == 14){
		newZoom = 16;
	}else if(zoom == 15){
		newZoom = 18;
	}else if(zoom == 16){
		newZoom = 18;
	}else if(zoom == 17){
		newZoom = 19;
	}else if(zoom == 18){
		newZoom = 20;
	}else if(zoom == 19){
		newZoom = 20;
	}else if(zoom == 20){
		newZoom = 21;
	}else if(zoom == 21){
		newZoom = 21;	
	}

	gp_map.setZoom(newZoom);

	gp_trackRightClick('Center and Zoom');
}

function gp_openRigthClickMenu(e){
	gp_map.set('disableDoubleClickZoom', true); //disable double click zoom becuase of FF zoom out bug

	//Find the pixel position in the map
	var overlay = new google.maps.OverlayView();
	overlay.draw = function() {};
	overlay.setMap(gp_map);
	var projection = overlay.getProjection(); 
	var pixel = projection.fromLatLngToContainerPixel(e.latLng);

	//Create on object with coordinates and mouse position
	var clickInfo = {
		lat: e.latLng.lat(),
		lng: e.latLng.lng(),
		x: pixel.x,
		y: pixel.y
	};

	//Save the lat lng of the click in rightClickLatLng var so other methods have access
	rightClickLatLng = clickInfo;

	//Show the right click menu
	showMapContextMenu(clickInfo);
}

function gp_searchRadialRemoteRightClick(){
	//Recenter map
	gp_map.panTo(new google.maps.LatLng(rightClickLatLng.lat, rightClickLatLng.lng));

	//Set the right click repositioned flag to true so original centerPOI is not used
	rightClickRepositionOccured = true;

	//Wipe out the old center point poi
	gp_centerPOI = {};

	//Do radial search
	gp_searchRadialRemote();

	gp_trackRightClick('Radial Search');
}

//Return an object with center info
function gp_getCenterObject(){
	var r = new Object();
	r.center = gp_map.getCenter();
	r.lat = r.center.lat();
	r.lng = r.center.lng();
	return r;
}

//Return an object with bounds
function gp_getBoundsObject(){
	var r = new Object();
	r.bounds = gp_map.getBounds();
	r.minLat = r.bounds.getSouthWest().lat();
	r.maxLat = r.bounds.getNorthEast().lat();
	r.minLng = r.bounds.getSouthWest().lng();
	r.maxLng = r.bounds.getNorthEast().lng();
	return r;
}

//A Best Fit function for Google Maps - depends upon the gp_bounds object being populated
function gp_centerZoom(){
	
	if (gp_activeMapMode == 'ROUTE' && typeof(gp_dir) != 'undefined'){
		gp_dir.setMap(gp_map);
	} else {
		if (gp_bounds.getCenter().lat() != 0 && gp_bounds.getCenter().lng() != -180){
			
			// Center
			gp_map.setCenter(gp_bounds.getCenter());
			
			// Zoom
			gp_map.fitBounds(gp_bounds);
			
			// an event listener will reset the zoom if its in too far
		}
	} 
	
}

// Open the Info Window
function gp_openPoiInfoMarker(markerID) {
	var marker = gp_markers[markerID];
	gp_infoWindow.setContent(marker.infoWindowHTML);
	gp_infoWindow.setPosition(marker.getPosition());
	gp_infoWindow.open(gp_map);
	gp_infoWindow.markerId = marker.uniqueID;
	gp_infoWindow.tabsDIV - null;
}

// Remove the marker from the map
function gp_removeMarkerMap(markerID) {

	// Remove marker from map
	gp_markers[markerID].setMap(null);

	//Remove selected checkbox marker for this marker
	if(gp_markers[markerID].selectedMarker){
		gp_markers[markerID].selectedMarker.setMap(null);
	}
	
	// Close info window if applicable
	if (markerID == gp_infoWindow.markerId){
		gp_infoWindow.close();
		gp_tooltip.hide();
	}
	
	// Remove from the gp_markers object
	delete gp_markers[markerID];
	
}

//Given a data set search collection name, remove those markers from the map
function gp_removeDataSetSearchFromMap(collectionName){

	//Loop through markers collection and remove those from map for the specified collection
	for(key in gp_markers){
		if(gp_markers[key].collectionName == collectionName){
			gp_markers[key].setMap(null);

			//Remove the selected checkbox marker if there is one for the search marker
			if(gp_markers[key].selectedMarker){
				gp_markers[key].selectedMarker.setMap(null);
			}

			// Close info window if applicable
			if (gp_markers[key].uniqueID == gp_infoWindow.markerId){
				gp_infoWindow.close();
				gp_tooltip.hide();
			}
		}
	}

	//Remove any circles on the map related to this search
	for(key in gp_cirOverlays){
		if(key == collectionName + '_overlay'){
			gp_cirOverlays[key].setMap(null);
		}
	}
}

function gp_removeDataSetSearchTab(collectionName){
	//Remove markers from gp_markers object
	for(key in gp_markers){
		if(gp_markers[key].collectionName == collectionName){
			delete gp_markers[key];
		}
	}

	//Remove circle from gp_cirOverlays object
	for(key in gp_cirOverlays){
		if(key == collectionName + '_overlay'){
			delete gp_cirOverlays[key];
		}
	}

	//Remove the tab and content
	jQuery(".dataSetResultTableTab[data-collectionName='"+collectionName+"']").remove();
	jQuery("#tabs-" + collectionName).remove();

	//If there no more result or route tabs show the no data message
	var $tabs = jQuery(".dataSetResultTableTab,#routeDirectionsTab");
	if($tabs.length == 0){
		jQuery("#gp_dataTablesNoData").show();
		jQuery("#gp_dataTables").hide();
	}else{ 
		jQuery($tabs[0]).find("a").click();
	}
}

function gp_restoreDataSetSearchOnMap(collectionName){
	//Loop through markers object and add those back to map for collectionName
	for(key in gp_markers){
		if(gp_markers[key].collectionName == collectionName){
			gp_markers[key].setMap(gp_map);

			//Restore the selected checkbox marker if there is one
			if(gp_markers[key].selectedMarker){
				gp_markers[key].selectedMarker.setMap(gp_map);
			}
		}
	}

	//Add back any necessary circles
	for(key in gp_cirOverlays){
		if(key == collectionName + '_overlay'){
			gp_cirOverlays[key].setMap(gp_map);
		}
	}
}

// Enable Street View
function gp_enableStreetView(lat,lng){
	jQuery("#mapContextMenu").hide();
	gp_map.getStreetView().setPosition(new google.maps.LatLng(lat,lng));
	gp_map.getStreetView().setVisible(true);
}


//Toggles the Traffic Overlay
function gp_toggleTraffic() {
	try{
		if (gp_trafficState) {
			gp_traffic.setMap(null);
			gp_trafficState = false;
			jQuery('#buttonTrafficLayer').val(jQuery('#buttonTrafficLayer').val().replace("Off","On"));
			gp_trackLayerToggle('Traffic','Off');
		} else {
			gp_traffic.setMap(gp_map);
			gp_trafficState = true;
			jQuery('#buttonTrafficLayer').val(jQuery('#buttonTrafficLayer').val().replace("On","Off"));
			gp_trackLayerToggle('Traffic','On');
		}
		return false;
	} catch(e){
		alert(e); 
		geopointeAjaxEnd();
		return false;
	}
}

//Toggles the Transit Overlay
function gp_toggleTransit() {
	try{
		if (gp_transitState) {
			gp_transit.setMap(null);
			gp_transitState = false;
			jQuery('#buttonTransitLayer').val(jQuery('#buttonTransitLayer').val().replace("Off","On"));
			gp_trackLayerToggle('Transit','Off');
		} else {
			gp_transit.setMap(gp_map);
			gp_transitState = true;
			jQuery('#buttonTransitLayer').val(jQuery('#buttonTransitLayer').val().replace("On","Off"));
			gp_trackLayerToggle('Transit','On');
		}
		return false;
	} catch(e){
		alert(e); 
		geopointeAjaxEnd();
		return false;
	}
}

//Toggles the Bicycling Overlay
function gp_toggleBicycling() {
	try{
		if (gp_bicyclingState) {
			gp_bicycling.setMap(null);
			gp_bicyclingState = false;
			jQuery('#buttonBicyclingLayer').val(jQuery('#buttonBicyclingLayer').val().replace("Off","On"));
			gp_trackLayerToggle('Bicycle','Off');
		} else {
			gp_bicycling.setMap(gp_map);
			gp_bicyclingState = true;
			jQuery('#buttonBicyclingLayer').val(jQuery('#buttonBicyclingLayer').val().replace("On","Off"));
			gp_trackLayerToggle('Bicycle','On');
		}
		return false;
	} catch(e){
		alert(e); 
		geopointeAjaxEnd();
		return false;
	}
}

//Toggles the Weather Overlay
function gp_toggleWeather() {
	try{
		if (gp_weatherState) {
			gp_weather.setMap(null);
			gp_weatherState = false;
			jQuery('#buttonWeatherLayer').val(jQuery('#buttonWeatherLayer').val().replace("Off","On"));
			gp_trackLayerToggle('Weather','Off');
		} else {
			gp_weather.setMap(gp_map);
			gp_weatherState = true;
			jQuery('#buttonWeatherLayer').val(jQuery('#buttonWeatherLayer').val().replace("On","Off"));
			gp_trackLayerToggle('Weather','On');
		}
		return false;
	} catch(e){
		alert(e); 
		geopointeAjaxEnd();
		return false;
	}
}

function __PLACES__(){}
//Add a Places result to the map as a layer
function gp_addPlaces(data){
	
	// NOKIA
	if (typeof(data.results) == "undefined"){return;}
	if (typeof(data.results.items) == "undefined"){return;}

	// icons are 60x65
	var icon_w = 60*.6; 
	var icon_h = 65*.6;
	
	gp_clearPlaces();
	
	var added = false;
	jQuery.each(data.results.items, function(index, poi) {
		
		if(poi.type=='urn:nlp-types:place'){
			var lat = poi.position[0];
			var lng = poi.position[1];
			if (!jQuery('#gp_placesRestrictSearchArea').is(':checked') || gp_latLngInBounds(lat,lng)){
				var g_latlon = new google.maps.LatLng(lat, lng);
				gp_placeBounds.extend(g_latlon);
				var placeInfo =	{	"gp_placeId":poi.id, 
									"gp_placeURL":poi.href,
									"gp_placeLat":lat,
									"gp_placeLng":lng,
									"gp_iconURL":poi.icon.replace("http://","https://"),
									"gp_iconW":icon_w,
									"gp_iconH":icon_h,
									"gp_placeSponsored":false
								}
				if(typeof(poi.sponsored)!="undefined"){if(poi.sponsored){obj.gp_placeSponsored=true;}}
				var g_icon = new google.maps.MarkerImage(	poi.icon.replace("http://","https://"),
															null,
															null,
															null,
															new google.maps.Size(icon_w,icon_h)
															);
				var g_marker = gp_createMarker(g_latlon, poi.title, 'TBD', g_icon, poi.id, placeInfo);
				if(poi.id != ''){
					gp_markersPlaces[poi.id] = g_marker;
				}
				g_marker.setMap(gp_map);
				added = true;
			}
		}
		
	});
	
	if (added){
		gp_centerZoom(16);
		gp_map.setCenter(gp_placeBounds.getCenter());
		gp_map.fitBounds(gp_placeBounds);
	} else {
		jQuery.jGrowl('No results were found that met your search criteria. You can try again by exposing a larger area on the map before you search.', { life: 5000 });
	}
	
}

function gp_clearPlaces(){
	gp_placeBounds = new google.maps.LatLngBounds();
	for(var i in gp_markersPlaces) {
		gp_markersPlaces[i].setMap(null);
	}
	gp_markersPlaces = new Object();
}

function gp_placesInfoWindowHandler(placeInfo,marker){
	var url = placeInfo.gp_placeURL.replace("http://","https://");
	jQuery.ajax({
		url: url,
		dataType: 'jsonp',
		type: 'GET',
		crossDomain: true,
		success: function(data, textStatus, XMLHttpRequest){
			var html = gp_buildPlacesInfoContent(data,placeInfo);
			gp_infoWindow.setContent(html);
			gp_infoWindow.setPosition(marker.getPosition());
			gp_infoWindow.open(gp_map);
			gp_infoWindow.markerId = marker.uniqueID;
			gp_infoWindow.tabsDIV = null;
			gp_tooltip.hide();
		}
	});
}

function __DEMOGRAPHICS__(){}
function gp_initDemoControls() {

	// Year
	jQuery("select#gp_demoYear").change(function () { gp_createDemoLayer(); });
    
    // Granularity
	jQuery("select#gp_demoGranularity").change(function () { 
		gp_setMinMax(); 
		gp_createDemoLayer(); 
	});
    
	// Metric
	jQuery("select#gp_demoMetric").append("<option  value=''> -- None --</option>");
    jQuery.each(gp_demoConfig.metrics, function (index, value) {
        jQuery("select#gp_demoMetric").append("<option id='metric" + index  + "' value='" + value.name + "'>" + value.label + "</option>");
    });
    jQuery("select#gp_demoMetric").change(function () {
    	gp_setMinMax();
    	gp_createDemoLayer();
    });
    
    // Sliders
    jQuery('#gp_demoFillOpacity').slider({
        range: "min",
        min: 0,
        max: 1,
        step: 0.1,
        value: 0.6
    }).bind("slidechange", function () {
        gp_createDemoLayer();
    });
    jQuery('#gp_demoBorderOpacity').slider({
        range: "min",
        min: 0,
        max: 1,
        step: 0.1,
        value: 0.4
    }).bind("slidechange", function () {
        gp_createDemoLayer();
    });

    // Min / Max Values
    jQuery("#gp_demoMinValue, #gp_demoMaxValue").change(function () {
    	gp_createDemoLayer();
    });
    
    // Legend
    jQuery("#gp_demoShowLegend").click(function () {
    	
    	var table = gp_buildLegendContents();
        
        jQuery('<div id="gp_demoLegend" style="padding: 5px 20px; font-size: 9pt;"></div>')
    	.append(table)
    	.append('<div style="padding: 5px 0;"><b>Tip:</b> Increase the Fill Opacity to see more distinct colors</div>')
		.dialog({
				modal: false, 
				draggable: true,
				position: { my: "right top", at: "right top", of: jQuery("#mapWrapper") },
				width: '300px', 
				title: 'Demographics Legend', 
				buttons: [
					{
						text: 'Close',
						click: function() {
							jQuery( this ).dialog( "close" );
						} 
					}
					],
				open: function(event, ui) {
						jQuery("#gp_demoShowLegend").prop('disabled', true);
					},
				close: function(event, ui) {
					jQuery("#gp_demoShowLegend").prop('disabled', false);
				}
		})
		
	});
    jQuery("#gp_demoShowLegend").prop('disabled', true);
    	
}

// Draws up the Demographics layer - https://developers.google.com/maps/documentation/business/demographics
function gp_createDemoLayer() {

	if (jQuery("select#gp_demoYear").val() == '' ||
		jQuery("select#gp_demoGranularity").val() == '' ||
		jQuery("select#gp_demoGranularity").val() == '-- None --' ||
		jQuery("select#gp_demoMetric").val() == '' || 
		jQuery("select#gp_demoMetric").val() == '-- None --' ||
		jQuery("#gp_demoMinValue").val() == '' || 
		jQuery("#gp_demoMaxValue").val() == '' || 
		isNaN(parseFloat(jQuery("#gp_demoMinValue").val())) || 
		isNaN(parseFloat(jQuery("#gp_demoMaxValue").val()))
		){
			jQuery("#gp_demoShowLegend").prop('disabled', true);
			gp_clearDemoLayer();

			//Remove the layers tab from being pinned if necessary
			if(gp_userSettings.settings__c[nameSpacePrefix + 'Pinned_Tabs__c'] && gp_userSettings.settings__c[nameSpacePrefix + 'Pinned_Tabs__c'].indexOf('layersPanel,') > -1 && jQuery("#pinLayersPanelCheckbox").is(':checked') == false ){ 
				gp_userSettings.settings__c[nameSpacePrefix + 'Pinned_Tabs__c'] = gp_userSettings.settings__c[nameSpacePrefix + 'Pinned_Tabs__c'].replace('layersPanel,',''); 
			}

			return;
		}
		
    //Make the layers tab pinned if it is not already
    if(gp_userSettings.settings__c[nameSpacePrefix + 'Pinned_Tabs__c'] && gp_userSettings.settings__c[nameSpacePrefix + 'Pinned_Tabs__c'].indexOf('layersPanel,') == -1){ 
		gp_userSettings.settings__c[nameSpacePrefix + 'Pinned_Tabs__c'] += 'layersPanel,'; 
	}

	// Draw Layer
	gp_clearDemoLayer();
    
    var min_value = parseFloat(jQuery("#gp_demoMinValue").val());
    var max_value = parseFloat(jQuery("#gp_demoMaxValue").val());
    var fillOpacity = jQuery("#gp_demoFillOpacity").slider("option", "value");
    var strokeOpacity = jQuery("#gp_demoBorderOpacity").slider("option", "value");
    var expression = jQuery("select#gp_demoMetric").val();
    var granularity = "us." + jQuery("select#gp_demoGranularity").val() + "." + jQuery("select#gp_demoYear").val();
    var dataSource = "us." + jQuery("select#gp_demoGranularity").val() + "." + jQuery("select#gp_demoYear").val();
    gp_demoLayer = new google.maps.visualization.DemographicsLayer({
        query: {
            from: dataSource,
            where: ''
        },
        style: [{
            polygonOptions: {
                fillOpacity: jQuery("#gp_demoFillOpacity").slider("option", "value"),
                fillColorStyle: {
                    expression: jQuery("select#gp_demoMetric").val(),
                    min: min_value,
                    max: max_value,
                    gradient: gp_demoConfig.gradientColors
                },
                strokeWeight: 1,
                strokeOpacity: jQuery("#gp_demoBorderOpacity").slider("option", "value"),
                strokeColor: '#000000'
            }
        }],
        map: gp_map,
        suppressInfoWindows: true
    });
    
    // Clean up other elements
    jQuery("#gp_demoShowLegend").prop('disabled', false);
    jQuery('#gp_demoLegendTable').html(gp_buildLegendContents().html());
    for(var i in gp_cirOverlays) {
		gp_cirOverlays[i].setMap(null);
	}
    for(var i in gp_kmlOverlays) {
    	gp_kmlOverlays[i].setMap(null);
	}
    
    gp_trackDemographics(dataSource, jQuery("select#gp_demoMetric").val());
    
    // InfoWindow handler
    google.maps.event.addListener(gp_demoLayer, 'click', function (data) {
        var d = data.featureDetails;
        
        var html =	'<table>';
        if (typeof(d.cbsa_name)!="undefined"){ html += '<tr><td><b>CBSA</b>:</td><td>' + d.cbsa_name + '</td></tr>'; }
        if (typeof(d.state_name)!="undefined"){ html += '<tr><td><b>State</b>:</td><td>' + d.state_name + '</td></tr>'; }
        if (typeof(d.county_name)!="undefined"){ html += '<tr><td><b>County</b>:</td><td>' + d.county_name + '</td></tr>'; }
        if (typeof(d.tract_name)!="undefined"){ html += '<tr><td><b>Tract</b>:</td><td>' + d.tract_name + '</td></tr>'; }
        if (typeof(d.block_group_name)!="undefined"){ html += '<tr><td><b>Block Group</b>:</td><td>' + d.block_group_name + '</td></tr>'; }
        html +=		'</table><hr/><table>' + 
        			'<tr><td><b>Size</b>:</td><td>' + gp_addCommasToNumber((d.area * 0.386102159).toFixed(3)) + ' Square Miles</td></tr>' + 
        			'<tr><td><b>Population</b>:</td><td>' + gp_addCommasToNumber(d.population) + '</td></tr>' +
        			'<tr><td><b>Population Per Sq. Mile</b>:</td><td>' + gp_addCommasToNumber((d.population/(d.area*0.386102159)).toFixed()) + '</td></tr>' +
        			
        			'<tr><td><b>Average Commute</b>:</td><td>' + d.commute_time_average + ' Minutes</td></tr>' + 
        			'</table>';
    	
        var md5 = jQuery.md5('' + new Date().getTime());
        var tabs = jQuery(	'<div>' + 
	        					'<div id="gp_demoTabs" style="background: transparent; margin: 10px;">' + 
							        '<ul style="background: transparent;">' + 
							        	'<li><a href="#tabs-1">Housing</a></li>' +
							        	'<li><a href="#tabs-2">Age / Gender</a></li>' + 
							        	'<li><a href="#tabs-3">Race</a></li>' + 
							        	'<li><a href="#tabs-4">Marital Status</a></li>' + 
						        	'</ul>' + 
							        '<div id="tabs-1">' +  
										'<table>' + 
											'<tr><td>Total Housing Units</td><td>' + gp_addCommasToNumber(d.housing_units) + '</td></tr>' +
											'<tr><td>% Owner Occupied</td><td>' + (d.owner_occupied_housing_units/d.housing_units*100).toFixed(2) + '</td></tr>' +
							    			'<tr><td>% Renter Occupied</td><td>' + (d.renter_occupied_housing_units/d.housing_units*100).toFixed(2) + '</td></tr>' +
							    			'<tr><td>Median Value (Owner Occupied)</td><td>$' + gp_addCommasToNumber(d.owner_occupied_value_median) + '</td></tr>' +
							    			'<tr><td>Average Household Size</td><td>' + d.household_size_average + '</td></tr>' +
											'<tr><td>Median Income</td><td>$' + gp_addCommasToNumber(d.household_income_median) + '</td></tr>' + 
							    			'<tr><td>Average Income</td><td>$' + gp_addCommasToNumber(d.household_income_average) + '</td></tr>' +
							    			'<tr><td>Average # of Vehicles</td><td>' + d.vehicles_per_household_average + '</td></tr>' +
										'</table>' + 
									'</div><div id="tabs-2">' +
										'<table>' + 
											'<tr><td>Average Age</td><td>' + d.age_average + '</td></tr>' +
											'<tr><td>Median Age</td><td>' + d.age_median + '</td></tr>' + 
							    			'<tr><td>Median Age (Male)</td><td>' + d.male_age_median  + '</td></tr>' +
							    			'<tr><td>Median Age (Female)</td><td>' + d.female_age_median  + '</td></tr>' +
							    			'<tr><td>% 16+</td><td>' + (d.population_16plus/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% 18+</td><td>' + (d.population_18plus/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% 21+</td><td>' + (d.population_21plus/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% 65+</td><td>' + (d.population_65plus/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Male</td><td>' + (d.male/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Female</td><td>' + (d.female/d.population*100).toFixed(2)  + '%</td></tr>' +
										'</table>' + 
									'</div><div id="tabs-3">' + 
										'<table>' + 
							    			'<tr><td>% African American</td><td>' + (d.black_or_african_american/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% American Indian / Alaska Native</td><td>' + (d.american_indian_or_alaska_native/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Asian</td><td>' + (d.asian/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Multi-Race</td><td>' + (d.multi_race/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Native Hawaiian / Pacific Islander</td><td>' + (d.native_hawaiian_or_pacific_islander/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Other Race</td><td>' + (d.other_race/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% White</td><td>' + (d.white/d.population*100).toFixed(2)  + '%</td></tr>' +
										'</table>' + 
									'</div><div id="tabs-4">' + 
										'<table>' + 
							    			'<tr><td>% Never Married</td><td>' + (d.never_married/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Married</td><td>' + (d.married/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Divorced</td><td>' + (d.divorced/d.population*100).toFixed(2)  + '%</td></tr>' +
							    			'<tr><td>% Widowed</td><td>' + (d.widowed/d.population*100).toFixed(2)  + '%</td></tr>' +
										'</table>' + 
									'</div>' + 
								'</div>' + 
							'</div>'
						);
    	
        gp_infoWindow.setContent('<div style="width:450px; height: 450px;">' + html + tabs.html() + '</div>');
		gp_infoWindow.setPosition(data.latLng);
		gp_infoWindow.tabsDIV = md5;
		gp_infoWindow.open(gp_map);
		gp_infoWindow.markerId = data.featureDetails.id;
    });
        
}

// Sets the Min value and Max value fields
function gp_setMinMax(){
	
	if (typeof(jQuery("select#gp_demoMetric :selected").attr("id"))=="undefined"){ return; }
	
	var index = jQuery("select#gp_demoMetric :selected").attr("id").replace("metric","");
    var metricConfig = gp_demoConfig.metrics[index];

    if (jQuery("select#gp_demoGranularity").val().match("block_group")) {
        if (metricConfig.max_block_group) {
            jQuery("#gp_demoMaxValue").attr("value", metricConfig.max_block_group);
            jQuery("#gp_demoMinValue").attr("value", metricConfig.min_block_group);
        } else {
            jQuery("#gp_demoMaxValue").attr("value", metricConfig.max);
            jQuery("#gp_demoMinValue").attr("value", metricConfig.min);
        }
    } else if (jQuery("select#gp_demoGranularity").val().match("tract")) {
        if (metricConfig.max_tract) {
            jQuery("#gp_demoMaxValue").attr("value", metricConfig.max_tract);
            jQuery("#gp_demoMinValue").attr("value", metricConfig.min_tract);
        } else {

            jQuery("#gp_demoMaxValue").attr("value", metricConfig.max);
            jQuery("#gp_demoMinValue").attr("value", metricConfig.min);
        }
    } else if (jQuery("select#gp_demoGranularity").val().match("county")) {
        if (metricConfig.max_county) {
            jQuery("#gp_demoMaxValue").attr("value", metricConfig.max_county);
            jQuery("#gp_demoMinValue").attr("value", metricConfig.min_county);
        } else {
            jQuery("#gp_demoMaxValue").attr("value", metricConfig.max);
            jQuery("#gp_demoMinValue").attr("value", metricConfig.min);
        }
    } else {
        jQuery("#gp_demoMaxValue").attr("value", metricConfig.max);
        jQuery("#gp_demoMinValue").attr("value", metricConfig.min);
    }
    
}

function gp_clearDemoLayer(){
	if (gp_demoLayer) {
        gp_demoLayer.setMap(null);
        for(var i in gp_cirOverlays) {
    		gp_cirOverlays[i].setMap(gp_map);
    	}
        for(var i in gp_kmlOverlays) {
        	gp_kmlOverlays[i].setMap(gp_map);
    	}
    }
}

function gp_buildLegendContents(){
	
	var fillOpacity = jQuery("#gp_demoFillOpacity").slider("option", "value");
	var min_value = parseFloat(jQuery("#gp_demoMinValue").val());
    var max_value = parseFloat(jQuery("#gp_demoMaxValue").val());
    var difference = (max_value - min_value) / jQuery(gp_demoConfig.gradientColors).size();
    
    var table = jQuery('<table id="gp_demoLegendTable" cellpadding="3"></table>');
    jQuery(gp_demoConfig.gradientColors).each(function(index,value){
    	var lowrange = min_value + (index * difference);
    	var highrange = lowrange + difference;
        table.append('<tr><td style="background-color:' + value + '; opacity:' + fillOpacity + '; width: 30px; height: 15px; border: 1px solid #C5C1C1;"></td><td style="text-align:right;">' + gp_addCommasToNumber(lowrange.toFixed(2)) + '</td><td style="text-align:center;" >&nbsp;-&nbsp;</td><td style="text-align:right;">' + gp_addCommasToNumber(highrange.toFixed(2)) + '</td></tr>');
    });
    
    return table;
}

function gp_updateSearchMarker(address,isGotoMyLocation){
	
	//1 Center the map on result
	gp_map.panTo(new google.maps.LatLng(address.lat,address.lng));

	if(gp_getZoomLevel() < 13){
		gp_map.setZoom(13);
	}

	//2 Remove existing center map marker if it exists
	if(gp_searchMarker != null &&  gp_markers['gp_mapSearchPoi']){ 
		gp_removeMarkerMap(gp_searchMarker.uniqueID);
		gp_searchMarker = null;
	}
	
	//3 Add new center map marker
	var g_latlon = new google.maps.LatLng(address.lat, address.lng);

	//Set option to keep center address for marker and "Search Center" on dataset 
	var keepCenterAddress = false;
	if(isGotoMyLocation || address.keepAddress){
		keepCenterAddress = true;
	}
	
	tmpInfoContentHTML = '';
	if(address.title){
		tmpInfoContentHTML += '<strong><u>'+address.title+'</u></strong>';
	}
	tmpInfoContentHTML += '<div>'+address.fullAddress+'</div>'+
	'<div style="margin: 5px 0; padding: 5px; background-color: #efebe2; line-height:1.5em;">'+
		'<span style="font-size: 10pt;"><b>Map Actions:</b></span><br/>'+
		'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_searchRadialRemote(' + address.lat + ',' + address.lng + ',' + keepCenterAddress +'); return false;">Radial Search</span>'+
		'&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_zoomToStreet(' + address.lat + ',' + address.lng + ',16);">Zoom &amp; Center</span><br/>'+
		'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_addToRouteSearchOrCenterPOI(gp_searchPOI,\'search\');">Add To Route</span>';
		//Only show this if was an address search, not a goto location
		if(isGotoMyLocation != true){
			tmpInfoContentHTML += '&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_addToMyLocations(gp_searchAddress);">Save To My Locations</span>';
		}
		tmpInfoContentHTML += '<br/><span style="text-decoration:underline; cursor:pointer;" onclick="gp_enableStreetView(' + address.lat + ',' + address.lng + ')">Street View</span>'+
		'&nbsp;&nbsp;<a href="http://maps.google.com?f=q&q='+ address.singleLineAddress +'" target="_blank">View on Google Maps</a>';
	'</div>';

	//Update html on searchPOI object
	if(gp_searchPOI){
		gp_searchPOI.markerHtml = tmpInfoContentHTML;
	}

	var g_marker = gp_createMarker(g_latlon
									, '<b>'+address.singleLineAddress+'</b>'
									,tmpInfoContentHTML 
									, searchPinURL
									, 'gp_mapSearchPoi');
	
	gp_markers[g_marker.uniqueID] = g_marker;
	gp_searchMarker = g_marker;
	g_marker.setMap(gp_map);
}

//--------DRAWING AND POLYGON/SHAPE SEARCH METHODS----------
var polygonObjects = {}; //keeps track of polygons on the map

function gp_enterDrawMode(params){ //{showNoShapeMsg:boolean}
	//Hide the data set search section and show the edit section
	jQuery("#dataSetSearchSection").hide();
	jQuery("#drawModeSection").show();

	//Make each of the fieldsets in the drawModeSection are the same height
	var highestHeight = 0;
	var $drawModeFieldSets = jQuery("#drawModeSection .fieldSet").each(function(){
		if(jQuery(this).height() > highestHeight){
			highestHeight = jQuery(this).height();
		}
	});
	$drawModeFieldSets.height(highestHeight);

	//If there are no shapes on the map show message about having to have shapes first
	if(params.showNoShapeMsg){
		jQuery('#noShapeMsg').show();
	}else{
		jQuery('#noShapeMsg').hide();
	}

	//Remove selected class from other drawtool buttons
	jQuery(".drawToolOption").removeClass('gpButtonSelected');
			
	//Add the selected class to the polygon drawtool
	jQuery("#drawPolygon").addClass('gpButtonSelected');

	//Set variable to keep track if filters where already open 
	filtersOpen = false;
	if(jQuery("#FiltersDIVOuter").is(':visible')){
		filtersOpen = true;	
	}

	//Hide the filters
	jQuery("#FiltersDIVOuter").hide();

	//Enable drawing mode
	gp_drawingManager.setMap(gp_map);

	//Default to polygon
	gp_drawingManager.setDrawingMode(google.maps.drawing.OverlayType.POLYGON);

	//Reset tab offset as height of panel changed
	resetMapControlOffset('#dataSetPanel');
}

function doPolygonSearch(params){ //{overlayId: id of shape, jqThis: jQuery(this)}
	//If there are no polygons add one to the map and do not perform the search
	if(jQuery.isEmptyObject(polygonObjects)){
		gp_enterDrawMode({'showNoShapeMsg':true});

	}else{
		
		//Show modal and track search
		geopointeAjaxStart('body','Performing a Shape Search...'); 
		gp_trackShapeSearch();

		//Create options object
		var options = {};
		options.searchType = 'shape';

		//Loop through all of the objects on the map and build bound boxes for each shape
		var shapeBoundBoxes = [];
		
		//If overlay id for a shape was defined only search this bound box
		if(params.overlayId){
			var bounds = polygonObjects[params.overlayId].getBounds();

			var boundBox = {
				minLat: bounds.getSouthWest().lat(),
				maxLat: bounds.getNorthEast().lat(),
				minLng: bounds.getSouthWest().lng(),
				maxLng: bounds.getNorthEast().lng()
			}
			shapeBoundBoxes.push(boundBox);

		}else{
			//Create search bounds for all of the shapes
			for(key in polygonObjects){
				var bounds = polygonObjects[key].getBounds();

				var boundBox = {
					minLat: bounds.getSouthWest().lat(),
					maxLat: bounds.getNorthEast().lat(),
					minLng: bounds.getSouthWest().lng(),
					maxLng: bounds.getNorthEast().lng()
				}
				shapeBoundBoxes.push(boundBox);
			}
		}

		//Add bound boxes to options
		options.shapeBoundBoxes = shapeBoundBoxes;

		//Show the data set section by 'clicking the back to search button'
		jQuery("#drawCancel").click();

		//Remove the center marker
		gp_removeCenterMarker();

		//Do the search and pass in the options
		gp_doSearch(options);

	}
}

function gp_shapeAddedToMap(overlay){
	
	//Put the map into hand mode if user has not pinned polygon draw tool mode
	//Remove selected class from other drawtool buttons
	jQuery(".drawToolOption").removeClass('gpButtonSelected');
		
	//Add the selected class to the hand drawtool
	jQuery("#drawHand").addClass('gpButtonSelected');

	//Default to polygon
	gp_drawingManager.setDrawingMode(null);

	//Create a unique Id for this overlay
	overlay.uniqueId = guid();

	//Set custom properties to empty string if they are null
	if(!overlay.sfdcName){
		overlay.sfdcName = '';
	}
	if(!overlay.sfdcDescription){
		overlay.sfdcDescription = '';
	}

	buildShapeBubbleHTML(overlay);

	//Add the polygon to the polygonObjects object to keep track of shapes on the map
	polygonObjects[overlay.uniqueId] = overlay;

	//Add event listener to the polygon overlay to open the infowindow popup bubble
	google.maps.event.addListener(overlay, 'click', function(e) {
		gp_infoWindow.setContent(overlay.htmlContent);
		gp_infoWindow.setPosition(e.latLng);
		gp_infoWindow.open(gp_map);
	});

	//Create a right click event listener on the shape to open the right click context menu
	google.maps.event.addListener(overlay, 'rightclick', function(e) {
		gp_openRigthClickMenu(e); //Open the right click menu
	});
}

function buildShapeBubbleHTML(overlay){
	
	//Only show delete button if record has sfdc id
	var deleteDisplay = 'none';
	if(overlay.sfdcId){
		deleteDisplay = '';
	}

	var html = '<div style="">'+
				'<div style="font-size: 10pt;"><b>Shape: </b><span id="shapeBubbleTitle">'+overlay.sfdcName+'</span></div>'+
				'<div id="shapeBubbleDescription">'+overlay.sfdcDescription+'</div>'+
				'<div class="shapeEditButtons">'+
				'<input type="button" class="btn" value="Search" onclick="doPolygonSearch({overlayId: \''+overlay.uniqueId+'\'}); return false;"/>'+
				'<input type="button" class="btn" value="Remove" onclick="gp_removeShape(\''+overlay.uniqueId+'\'); return false;"/>'+
				'<input type="button" class="btn" value="Save" onclick="gp_saveShape(\''+overlay.uniqueId+'\'); return false;"/>'+
				'<input type="button" class="btn" style="display: '+deleteDisplay+';" id="shapeDelBtn" value="Delete" onclick="gp_deleteShape(\''+overlay.uniqueId+'\'); return false;"/>'+
				'</div>'+
				'<div style="height: 165px; margin-left: 4px;" class="gp_ShapeColorDiv"><input type="text" class="gp_shapeColorInput" data-shapeId="'+overlay.uniqueId+'" value="E7DC40" id="shapeColor'+overlay.uniqueId+'"/></div>'+
				'<style>.gp_ShapeColorDiv .minicolors-theme-geopointe .minicolors-panel{top: 4px}</style>'+
				'</div>';

	overlay.htmlContent = html;
}

function gp_saveShape(uniqueId){
	//Get the shape from the polygonObjects object
	var polygon = polygonObjects[uniqueId];

	var title = 'Save Shape';
	if(polygon.sfdcName){
		title += ' - ' + polygon.sfdcName;
	}

	var buttonText = 'Save';
	var body = 'Enter a Name and Short Description for the shape that will be saved.<br/>'+
				'<table>'+
				'<tr><td class="saveShapeLabel">Name</td><td><input type="text" value="'+polygon.sfdcName+'" id="gp_saveShapeName"/></td></tr>'+
				'<tr><td class="saveShapeLabel alignTop">Description</td><td><textarea style="height: 50px; width: 200px;" id="gp_saveShapeDescription">'+polygon.sfdcDescription+'</textarea></td></tr>'+
				'</table>';

	jQuery('<div></div>')
		.append('<p>'+body+'</p>')
		.dialog({
			modal: true, 
			draggable: false, 
			width: '515px', 
			title: title, 
			position: { my: "bottom", at: "center", of: window },
			open: function() {
		      	//Create Enter event listner
		      	jQuery('#gp_saveShapeName').keypress(function(e) {
				    if (e.keyCode == 13) {
				    	//Click the first button in this modal, which is the OK button
				    	jQuery(this).parents(".ui-dialog").find("button").first().click();
				    }
				});		      	
		    },

		    buttons:[{text: buttonText, 
		    			click: function(){ 
		    		   		var name = jQuery("#gp_saveShapeName").val();	
		    		   		var description = jQuery("#gp_saveShapeDescription").val();		
		    				
		    				//Proceed if name was supplied
		    		   		if(name){

		    		   			//Close this dialog
								jQuery( this ).remove();

								geopointeAjaxStart('body','Saving Shape...');
								
								//Build a Shape__c object
								var shape = {};
								shape.Id = polygon.sfdcId;
								shape.Name = name;
								shape[nameSpacePrefix + 'Description__c'] = description;
								shape[nameSpacePrefix + 'Color__c'] = polygon.fillColor;
								shape[nameSpacePrefix + 'Opacity__c'] =  polygon.fillOpacity;
								shape[nameSpacePrefix + 'Type__c'] = 'Polygon';


								//Build a lat lng encoded polyline
								var latLngEncoded = google.maps.geometry.encoding.encodePath(polygon.getPath());
							
								//Save the shape
								Visualforce.remoting.Manager.invokeAction(saveShapeRemoteMethodName,shape,latLngEncoded,function(result, event){
									if (event.status) { //Success
										
										//Update the object stored in polygonObjects
										polygon.sfdcName = name;
										polygon.sfdcDescription = description;
										polygon.sfdcId = result.Id;

										//Update the open shape bubble
										jQuery("#shapeBubbleTitle").text(name);
				                    	jQuery("#shapeBubbleDescription").text(description);
				                    	jQuery("#shapeDelBtn").show();

				                    	//Update the html for the shape bubble
				                    	buildShapeBubbleHTML(polygon);

										//Update the picklist of saved shapes, first check to see if there is already a picklist value for this shape
										gp_rerenderShapeListAdd(result.Id); //actionFunction on map.page

									} else {
										//Error handling
										var message = {
											severity: 'ERROR',
											message: 'Uh oh. Something didn\'t work quite right. If this error continues please contact Arrowpointe support. '+ event.message
										};
										updatePageMessages([message]);
										gp_track('Error', {'Language': 'JavaScript', 'Type':'Remoting', 'Function':'saveShape', 'Message':event.message});

										geopointeAjaxEnd();
									}
								},
									{escape: true}
								);
							}	
		    			} 
		    		},
		    		{text: "Cancel", 
		    			click: function(){ 
		    		   		jQuery( this ).remove(); 
		    			} 
		    		}] 
	});
}

function gp_addShapeToMap(){
	
	//Get the Id of the currently selected shape
	var sfdcShapeId = jQuery("#shapeList").val();

	if(sfdcShapeId && sfdcShapeId != '--None--'){

		//Check to see if shape is already on the map
		for(key in polygonObjects){
			if(sfdcShapeId == polygonObjects[key].sfdcId){
				geopointeAjaxEnd();
				
				var polygon = polygonObjects[key];

				var title = 'Duplicate Shape';
				var body = 'The shape <b>'+ polygon.sfdcName +'</b> has already been added to the map.<br/><br/>'+
							'You can view this shape by selecting the \'Go To Shape\' button below.';

				jQuery('<div></div>')
					.append('<p>'+body+'</p>')
					.dialog({
						modal: true, 
						draggable: false, 
						width: '515px', 
						title: title, 
						position: { my: "bottom", at: "center", of: window },
						open: function() {
					      	//Create Enter event listner
					      	jQuery('#gp_saveShapeName').keypress(function(e) {
							    if (e.keyCode == 13) {
							    	//Click the first button in this modal, which is the OK button
							    	jQuery(this).parents(".ui-dialog").find("button").first().click();
							    }
							});		      	
					    },

					    buttons:[{text: 'Go To Shape', 
					    			click: function(){ 
					    		   		gp_bounds = new google.maps.LatLngBounds();

					    		   		var paths = polygon.getPaths();

										for (var p = 0; p < paths.getLength(); p++) {
											var path = paths.getAt(p);
											for (var i = 0; i < path.getLength(); i++) {
												gp_bounds.extend(path.getAt(i));
											}
										}

										//Readjust the map
										gp_centerZoom();

										//Close this dialog modal
										jQuery( this ).remove(); 
					    			} 
					    		},
					    		{text: "Cancel", 
					    			click: function(){ 
					    		   		jQuery( this ).remove(); 
					    			} 
					    		}] 
				});
				//Do not proceed with add shape to map
				return false;
			}
		}

		geopointeAjaxStart('#drawModeSection','Adding Shape...');

		//Get the shape coordinates
		Visualforce.remoting.Manager.invokeAction(getShapeLatLngRemoteMethodName,sfdcShapeId,function(result, event){
			if (event.status) {
				
				//Decode the lat lng string stored in sfdc, multiple lat lng fields are combined into Lat_Lng_1__c
				var latLngs = google.maps.geometry.encoding.decodePath(result[nameSpacePrefix + 'Lat_Lng_1__c']);

				//Create a new polygon overlay
				var shape = new google.maps.Polygon({
					paths: latLngs,
					fillColor: result[nameSpacePrefix + 'Color__c'],
					fillOpacity: result[nameSpacePrefix + 'Opacity__c'],
					strokeWeight: 1.5,
					clickable: true,
					zIndex: 1,
					editable: true,
					draggable: true
				});

				//Set the saved properties on the overlay shape object
				shape.sfdcId = result.Id;
				shape.sfdcName = result.Name;
				shape.sfdcDescription = result[nameSpacePrefix + 'Description__c'];

				//Add the shape to map
				shape.setMap(gp_map);

				//Call polygon added to map method, make sure it is added to polygon Objects array
				gp_shapeAddedToMap(shape);

				//Make sure bounds of map include the shape
				for (var i = 0; i < latLngs.length; i++) {
					gp_bounds.extend(latLngs[i]);
				}

				//Readjust the map
				gp_centerZoom();

				//Remove the ajax status modal
				geopointeAjaxEnd();	

			} else {
				//Error handling
				var message = {
					severity: 'ERROR',
					message: 'Uh oh. Something didn\'t work quite right. If this error continues please contact Arrowpointe support. '+ event.message
				};
				updatePageMessages([message]);
				gp_track('Error', {'Language': 'JavaScript', 'Type':'Remoting', 'Function':'gp_addShapeToMap', 'Message':event.message});

				geopointeAjaxEnd();
			}
		},
			{escape: false}
		);
	}
}

function gp_deleteShape(uniqueId){
	//Get the current data set
	var polygon = polygonObjects[uniqueId];

	//Set the dialog title and body
	var title = 'Delete Shape - ' + polygon.sfdcName;
	var body = 'This will DELETE the <b>'+ polygon.sfdcName +'</b> Shape and remove it from your list of saved shapes.';

	jQuery('<div></div>')
		.append('<p>'+body+'</p>')
		.dialog({
				modal: true, 
				draggable: false, 
				width: '515px', 
				title: title, 
				position: { my: "bottom", at: "center", of: window },

			    buttons:[{text: 'Delete', 
			    			click: function(){ 
			    		   		
			    		   		geopointeAjaxStart('body','Deleting Shape...');

			    		   		//Close this dialog
								jQuery( this ).remove();

								//Remoting save methods for dataSet
								Visualforce.remoting.Manager.invokeAction(deleteShapeRemoteMethodName,polygon.sfdcId,function(result, event){
									if (event.status) {
										
										//Remove this data set from the shape picklist by rerendering it
										gp_rerenderShapeListRemove(); //actionFunction on map.page

										//Remove the data set from polygon objects and map
										gp_removeShape(polygon.uniqueId);

									} else {
										//Error handling
										var message = {
											severity: 'ERROR',
											message: 'Uh oh. Something didn\'t work quite right. If this error continues please contact Arrowpointe support. '+ event.message
										};
										updatePageMessages([message]);
										gp_track('Error', {'Language': 'JavaScript', 'Type':'Remoting', 'Function':'dataShape', 'Message':event.message});

										geopointeAjaxEnd();
									}
								},
									{escape: true}
								);
							}
			    		},
			    		{text: "Cancel", 
			    			click: function(){ 
			    		   		jQuery( this ).remove(); 
			    			} 
			    		}] 
				});
}

function gp_removeShape(uniqueId){
	//Remove from map
	polygonObjects[uniqueId].setMap(null);

	//Remove from polygonObjects object
	delete polygonObjects[uniqueId];

	//Close the info window
	gp_infoWindow.close();
}

function gp_removeAllShapesFromMap(){
	jQuery('<div></div>')
		.append('<p>This will remove all shapes from the map.<br/><br/>Select \'Remove\' to continue.</p>')
		.dialog({
			modal: true, 
			draggable: false, 
			width: '270px', 
			title: 'Remove All Shapes', 
			position: { my: "bottom", at: "center", of: window },
			
		    buttons:[{text: "Remove", 
		    			click: function(){ 
		    				//Remove shapes from the map
							for(key in polygonObjects){
								polygonObjects[key].setMap(null);		
							}

							//Empty the polygonObjects object
							polygonObjects = {};

							//Close info window that may be open
							gp_infoWindow.close();	

							//Close this dialog
							jQuery( this ).remove(); 
		    			} 
		    		},
		    		{text: "Cancel", 
		    			click: function(){ 
		    		   		jQuery( this ).remove(); 
		    			} 
		    		}] 
		});
}

function checkIfPoiInShapes(poi){
	
	//Construct a google lat lng object from the poi
	var latLng = new google.maps.LatLng(poi.lat,poi.lng);

	for(key in polygonObjects){	

		var isWithinPolygon = google.maps.geometry.poly.containsLocation(latLng,polygonObjects[key]);

		if(isWithinPolygon == true){
			return true;
		}
	}

	//Poi is not inside a shape
	return false;
}

//Extend the google Polygon object with getBounds - https://github.com/tparkin/Google-Maps-Point-in-Polygon, DONT USE containsLatLng() from this, has bugs use, google.maps.geometry.poly.containsLocation
if (!google.maps.Polygon.prototype.getBounds) {
  google.maps.Polygon.prototype.getBounds = function(latLng) {
    var bounds = new google.maps.LatLngBounds();
    var paths = this.getPaths();
    var path;
    
    for (var p = 0; p < paths.getLength(); p++) {
      path = paths.getAt(p);
      for (var i = 0; i < path.getLength(); i++) {
        bounds.extend(path.getAt(i));
      }
    }

    return bounds;
  }
}

/* Layer methods */
function gp_initLayerObject(layers){
	gp_layers = {};
	for(var i = 0; i < layers.length; i++){
		gp_layers[ layers[i][nameSpacePrefix + 'URL__c'] ] = layers[i];
	}
}

function gp_autoLoadLayers(){
	for(key in gp_layers){
		var layer = gp_layers[key];
		if(layer[nameSpacePrefix + 'Auto_Load__c'] == true){
			gp_addLayer({'url': layer[nameSpacePrefix + 'URL__c'], 'showStatus': false, 'isAutoLoad':true});
		}
	}
}

function gp_toggleLayer($this,event){ //$this is jQuery(this)

	var url = $this.attr('data-url'); //Get layer url from element clicked in layer table
	var layer = gp_layers[url];
	var kmlLayer = layer.kmlLayer; //google.maps.KmlLayer class

	//If there is google kml layer and this kml layer is on the map, need to remove
	if(kmlLayer && kmlLayer.getMap()){
		//Remove layer, remove green dot from layer table, change layer action text
		kmlLayer.setMap(null);
		$this.closest('tr').find('.layerGreenDot').css('visibility','hidden');
		$this.closest('tr').find('.zoomToShowLayer').addClass('actionLinkDisabled');
		$this.text('Add');

		//Reset tab offset so tabs position correctly
		resetMapControlOffset('#layersPanel');

		//Track layer removal
		gp_track('Layer', {	"Layer Type": 'KML', 
						"Layer Status": 'Off' 
						});
	
	}else if(kmlLayer && kmlLayer.getStatus() == 'OK'){ //KML layer exists but it is not on map, its cached so dont show status modal as it will be added quickly
		gp_addLayer({'url': url, '$this': $this, 'showStatus': false, 'isAutoLoad': false});
	
	}else{//Add layer and show ajax status
		gp_addLayer({'url': url, '$this': $this, 'showStatus': true, 'isAutoLoad': false});

	}
	//Prevent normal link behavior
	event.preventDefault();
}

function gp_addLayer(opts){ //recieves opts object with arguments {url: string, this: jQuery(this)}	
	//Create a new layer object
	var layer = new google.maps.KmlLayer({
		url: opts.url,
		preserveViewport: true,
		map: gp_map
	});

	//Event listener to track if the kml layer was added to map successfully
	google.maps.event.addListener(layer, 'status_changed', function(kmlEvent) {
		if(layer.getStatus() == 'OK'){
				
			//On success update text and show the little green dot indicating layer is visible on map
			if(opts.url){

				jQuery("#layersTable tr[data-url='"+opts.url+"']")

				//Show remove green dot in layer table, change layer action text
				jQuery("#layersTable tr[data-url='"+opts.url+"']").find('.layerGreenDot').css('visibility','visible');
				jQuery("#layersTable tr[data-url='"+opts.url+"']").find('.zoomToShowLayer').removeClass('actionLinkDisabled');
				jQuery("#layersTable tr[data-url='"+opts.url+"']").find('.addRemoveLayer').text('Remove');

				//Reset tab offset so tabs position correctly
				resetMapControlOffset('#layersPanel');

				geopointeAjaxEnd();
			}
		}else{
			//Remove Ajax status icon
			geopointeAjaxEnd();

			//'Remove' layer from the map as it was never added successfully
			layer.setMap(null);

			var layerMessage;
			var status = layer.getStatus();

			if(status == 'DOCUMENT_NOT_FOUND'){
				layerMessage = 'The layer could not be added to the map.<br/><br/>Unable to locate the file. Make sure it is a publically accessible URL.';

			}else if(status == 'DOCUMENT_TOO_LARGE'){
				layerMessage = 'The layer could not be added to the map. The file is too large.<br/><br/>'+ 
								'See <a href="http://support.arrowpointe.com/layers/" target="_blank">http://support.arrowpointe.com/layers/</a> for more information on limits.';

			}else if(status == 'FETCH_ERROR'){
				layerMessage = 'The layer could not be added to the map.<br/><br/>Unable to fetch the file.';

			}else if(status == 'INVALID_DOCUMENT'){
				layerMessage = 'The layer could not be added to the map.<br/><br/>The document is not a well formed KML, KMZ, or GEORSS file.';

			}else if(status == 'INVALID_REQUEST'){
				layerMessage = 'The layer could not be added to the map.<br/><br/>The KmlLayer is invalid.';
				
			}else if(status == 'LIMITS_EXCEEDED'){
				layerMessage = 'The layer could not be added to the map. The document exceeds the limit of supported features.<br/><br/>'+ 
								'See <a href="http://support.arrowpointe.com/layers/" target="_blank">http://support.arrowpointe.com/layers/</a> for more information on limits.';

			}else if (status == 'TIMED_OUT'){
				layerMessage = 'The layer could not be added to the map.<br/><br/>Connection timeout.';

			}else{
				layerMessage = 'The layer could not be added to the map.<br/><br/>Please contact Arrowpointe Support if you continue to see this error.';
			}

			jQuery('<div style="margin-top: 4px;"></div>')
			.append('<div class="gp-alert gp-alert-error">'+layerMessage+'<div>')
			.dialog({
				modal: true, 
				draggable: true, 
				width: 350,
				title: 'Layer Error', 
				draggable: false,
				resizable: false,
				buttons: { 
					Close: function() {jQuery( this ).remove();} 
				}
			});

			//Put focus on the close button of the dialog
			jQuery(".ui-dialog-buttonset button").focus();
		}
	});

	//Show status message
	if(opts.showStatus){
		geopointeAjaxStart('body','Adding Layer...');
	}

	//Add layer to map
	layer.setMap(gp_map);

	//update kml object
	gp_layers[opts.url].kmlLayer = layer;

	//Log layer being added in mixpanel
	gp_track('Layer', {	"Layer Type": 'KML', 
						"Layer Status": 'On',
						"Is Auto Load": opts.isAutoLoad
						});
}
/* End Layer Methods */

