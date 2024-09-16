# Importing all necessary libraries and modules
import ee
import geemap
import osmnx as ox
import geopandas as gpd


# Triggering the authentication flow for Earth Engine (Used for open source satellite datasets)
ee.Authenticate()

# Initialize the library for resources
ee.Initialize(project='egovfoundations-sg')

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Defining Functions
def goal1(ward):
    # Goal 1 - Interactive map with different features on any selected ward
    # Importing datasets, shapefiles and libraries
    Map = geemap.Map(height='540px')
    buildings_data = ee.FeatureCollection("GOOGLE/Research/open-buildings/v3/polygons")
    dataset = ee.ImageCollection("GLCF/GLS_WATER")
    delhisf = ee.FeatureCollection("projects/egovfoundations-sg/assets/Delhi")
    delhiwards_db = ee.FeatureCollection("projects/egovfoundations-sg/assets/Delhi_Ward_Boundary_2022")
    population_data = ee.ImageCollection("CIESIN/GPWv411/GPW_Population_Count")
    DelhiRoads2 = ee.FeatureCollection("projects/egovfoundations-sg/assets/DelhiRoads2")

    # Global Inland Water Bodies
    roi = ee.FeatureCollection(delhisf).geometry()
    water = dataset.select('water')
    water1 = water.filter(ee.Filter.bounds(roi))
    waterVis = {
        'min': 1.0,
        'max': 4.0,
        'palette': ['fafafa', '00c5ff', 'df73ff', '828282', 'cccccc'],
    }
    water1_median = water1.median()
    water1_clip = water1_median.clip(roi)
    Map.addLayer(water1_clip, waterVis, 'InLand Water Bodies', False)
    Map.addLayer(delhisf,{'color': 'black'}, 'Delhi Shape File', False, 0.6)

    # Population Density
    filter_population = population_data.first().clip(delhisf)
    raster_vis = {
        'max': 10000.0,
        'palette': [
        'ffffe7',
        'FFc869',
        'ffac1d',
        'e17735',
        'f2552c',
        '9f0c21'
        ],
        'min': 0.0
    }
    Map.addLayer(filter_population,raster_vis,'Population_Density', True, 1)

    # Selecting Region of Interest (ROI) from available wards in Delhi
    x = ee.String(ward) #Just change the ward name here
    roi_ward = delhiwards_db.filter(ee.Filter.eq("sourceward",x))
    Map.addLayer(delhiwards_db,{'color': 'green'}, 'Delhi Wards Shape File', True, 0.7)
    Map.addLayer(roi_ward,{'color': 'red'}, 'Chosen Ward', True, 1)

    # Buildings detection
    roi_houses = buildings_data.filterBounds(roi_ward)
    count = roi_houses.size()
    Map.addLayer(roi_houses, {'color': 'yellow'}, 'Houses', True, 0.3)
    print("Number of Building Detected:",count.getInfo())

    # Roads Network
    roi_roads1 = DelhiRoads2.filter(ee.Filter.bounds(roi_ward))
    Map.addLayer(roi_roads1,{'color': 'blue'}, 'Delhi Roads', True, 0.6)

    # Calculating Area of ROI
    roi_area = roi_ward.geometry().area()
    roi_area_sqkm = ee.Number(roi_area).divide(1e6)
    print("Area of the Ward is: (in Sq Km)",roi_area_sqkm.getInfo())

    # Displaying the interactive maps with all the features
    scale = Map.getScale() * 3
    centroid = roi_ward.geometry().centroid()
    Map.centerObject(centroid, 15)
    display(Map)

def goal21():
    while True:
        print("\nChoose the facility:")
        print("1. Central Warehousing Corporation")    
        print("2. JIECANG Delhi Warehouse")
        print("3. Godown")
        print("4. Shalimar Warehouse")
        print("5. Exit")
        opt=int(input("Enter Your Facility Number (1/2/3/4/5 : )"))
        
        if opt in (1, 2, 3, 4):
            print("Selected choice:",opt)
            return(opt)
        else:
            continue
        
    
def goal2():
    # Warehouses data
    names_dict = {
        "Central Warehousing Corporation":"28.69437621403761,77.18850262865577",
        "JIECANG Delhi Warehouse":"28.70036585373791,77.16559231291417",
        "Godown":"28.6555777067871,77.23088934737488",
        "Shalimar Warehouse":"28.68086031003555,77.14947760145868"
    }

    keys_list = list(names_dict.keys())

    print("\nStarting Facility:")
    index = goal21()
    index = index - 1

    selected_name = keys_list[index]
    selected_value = names_dict[selected_name]
    print(f"Selected starting warehouse: {selected_name}")
    print(f"location: {selected_value}")
    start_name = selected_name
    start_value = selected_value

    print("\nDestination Facility:")
    index1 = goal21()
    index1 = index1 - 1

    selected_name1 = keys_list[index1]
    selected_value1 = names_dict[selected_name1]
    print(f"Selected destination warehouse: {selected_name1}")
    print(f"location: {selected_value1}")
    dest_name = selected_name1
    dest_value = selected_value1

    print("Shortest path between ",start_name," and ",dest_name,":")

    # Region to load
    center_point = (28.69437621403761, 77.18850262865577) #center point of delhi
    G = ox.graph_from_point(center_point, dist=4000, network_type='all')

    # Converting the obtained long and lat from string type to float type
    def conversion(argument):
        string = argument
        longitude, latitude = string.split(",")
        longitude = float(longitude)
        latitude = float(latitude)
        formatted_output = longitude,latitude
        return formatted_output

    # Coordinates
    kzh_lat, kzh_lon = conversion(start_value)
    mdcl_lat, mdcl_lon = conversion(dest_value)

    # Fetching the nearest node w.r.t coordinates
    kzh_node = ox.distance.nearest_nodes(G, kzh_lon, kzh_lat)
    mdcl_node = ox.distance.nearest_nodes(G, mdcl_lon, mdcl_lat)
    orig, dest = kzh_node, mdcl_node

    # Finding shortest path
    route_nodes = ox.routing.shortest_path(G, orig, dest, weight="length")

    def generate_multindex(route_nodes):
        multiindex_list = []
        # append the index to list
        for u, v in zip(route_nodes[:-1], route_nodes[1:]):
            multiindex_list.append((u, v, 0))
        return multiindex_list

    # get edges from from above multidigraph
    gdf_nodes, gdf_edges = ox.graph_to_gdfs(G)

    # generate multiindex based on generated shortest route
    multiindex_list = generate_multindex(route_nodes)
    # fetch edge details based on multi index list
    shrt_gdf_edges = gdf_edges[gdf_edges.index.isin(multiindex_list)]


    # Create an interactive Geemap
    Map = geemap.Map()
    Map.setCenter(77.18850262865577,28.69437621403761,11) #center point of delhi
    Map.add_gdf(shrt_gdf_edges, 'Shortest Path')

    # Adding legends
    legend_dict = {
        start_name : (255,0,0),
        dest_name : (0,0,255)
    }
    Map.add_legend(legend_title='Warehouses', legend_dict=legend_dict, position='bottomleft')

    # Adding markers for the warehouses
    point_feature = ee.Feature(ee.Geometry.Point(kzh_lon, kzh_lat), {'label': 'Start_Point'})
    point_fc = ee.FeatureCollection([point_feature])
    Map.add_layer(point_fc, {'color': 'red', 'radius': 20, 'fillColor': 'red'}, 'Start_Point')

    point_feature1 = ee.Feature(ee.Geometry.Point(mdcl_lon, mdcl_lat), {'label': 'Dest_Point'})
    point_fc1 = ee.FeatureCollection([point_feature1])
    Map.add_layer(point_fc1, {'color': 'blue', 'radius': 20, 'fillColor': 'blue'}, 'Dest_Point')

    display(Map)

def goal3():
    # Warehouses data
    names_dict = {
        "Central Warehousing Corporation":"28.69437621403761,77.18850262865577",
        "JIECANG Delhi Warehouse":"28.70036585373791,77.16559231291417",
        "Godown":"28.6555777067871,77.23088934737488",
        "Shalimar Warehouse":"28.68086031003555,77.14947760145868"
    }

    keys_list = list(names_dict.keys())

    index = goal21()
    index = index - 1

    selected_name = keys_list[index]
    selected_value = names_dict[selected_name]
    print(f"Selected Warehouse: {selected_name}")
    print(f"location: {selected_value}")
    start_name = selected_name
    start_value = selected_value

    # Converting the obtained long and lat from string type to float type
    def conversion(argument):
        string = argument
        longitude, latitude = string.split(",")
        longitude = float(longitude)
        latitude = float(latitude)
        formatted_output = longitude,latitude
        return formatted_output

    # Loading map
    Map = geemap.Map(height='540px')

    #Point of Interest, defining common long and lats
    #poi_longitude, poi_latitude = 28.69437621403761, 77.18850262865577
    poi_longitude, poi_latitude = conversion(start_value)

    #Region of interest around the warehouse
    radius_of_interest_meters = 1500
    area_of_interest = ee.Geometry.Point([poi_latitude, poi_longitude]).buffer(radius_of_interest_meters)
    Map.addLayer(area_of_interest, {'color': 'green'}, 'Central Warehousing Corporation', True, 0.8)
    Map.centerObject(area_of_interest, 12)

    # Extract street network
    center_point = (poi_longitude, poi_latitude)
    G = ox.graph_from_point(center_point, dist=1200, network_type='all')
    nodes, edges = ox.graph_to_gdfs(G)

    # Add street network as a GeoPandas layer
    Map.add_gdf(edges, layer_name='Streets')

    display(Map)


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#starting the program

#test account -> numpasswordcracker, Password -> 192837 , have put this password in 

print("------------------------------------------------------------------------------")
print("                                                                              ")
print(" Dedicated Mentorship Program - Code 4 Gov Tech under eGovernment Foundations ")
print("                                                                              ")
print("                             OPEN SOURCE GIS TOOL                             ")
print("                                                                              ")
print("------------------------------------------------------------------------------")

c='y'
while (c=='y' or c=='Y'):
    print("Welcome to the Open Source GIS Tool")
    print("1. Interactive GIS Tool with multiple feature levels for a specific ward")    
    print("2. Find shortest distance between two facilities")
    print("3. Find area covered / serviced by a facility")
    print("4. EXIT ")
    opt=int(input("Enter Your Choice (1/2/3/4 : )"))
    if opt==1:
        print("\nLoading Interactive Map with multiple feature levels...")
        ward = str(input("Enter name of the ward of interest:"))
        goal1(ward)
        

    elif opt==2:
        print("\nLoading shortest distance feature...")
        goal2()

    elif opt==3:
        print("\nLoading area served feature....")
        goal3()
    else:
        break
        
            
    c=input("\n Do you want to continue  y/n :")

print("Thank you for choosing us!!")
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------