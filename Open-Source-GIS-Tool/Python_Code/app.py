import streamlit as st
import osmnx as ox
import geojson
import csv
import leafmap
from streamlit_folium import folium_static
import leafmap.foliumap as leafmap
import geemap.foliumap as geemap

def facility_area_served():
    ababab = st.text_input("Working...")
    Facilities = []

    #Taking the map from the user
    st.write("Please enter the coordinates. Eg: For New Delhi (28.645307, 77.224662)")
    #latitude = float(input("Enter latitude: "))
    #longitude = float(input("Enter longitude: "))
    latitude = float(28.6561681)
    longitude = float(77.2342614)
    st.write("Entered:",latitude, longitude)
    center_point = (latitude, longitude)
    G = ox.graph_from_point(center_point, dist=900, network_type='all')

    # Facility 1
    st.write("Please enter the coordinates of Facility 1:")
    #latitude1 = float(input("Enter latitude: "))
    #longitude1 = float(input("Enter longitude: "))
    latitude1 = float(28.6576419)
    longitude1 = float(77.2292175)
    st.write("Entered:",latitude1, longitude1)
    x = list((longitude1,latitude1))
    Facilities.append(x)
    node_f1 = ox.distance.nearest_nodes(G, longitude1, latitude1)

    # Facility 2
    st.write("Please enter the coordinates of Facility 2:")
    #latitude2 = float(input("Enter latitude: "))
    #longitude2 = float(input("Enter longitude: "))
    latitude2 = float(28.6538828)
    longitude2 = float(77.2319103)
    st.write("Entered:",latitude2, longitude2)
    x = list((longitude2,latitude2))
    Facilities.append(x)
    node_f2 = ox.distance.nearest_nodes(G, longitude2, latitude2)

    # Facility 3
    st.write("Please enter the coordinates of Facility 3:")
    #latitude2 = float(input("Enter latitude: "))
    #longitude2 = float(input("Enter longitude: "))
    latitude3 = float(28.6570721)
    longitude3 = float(77.2352708)
    st.write("Entered:",latitude3, longitude3)
    x = list((longitude3,latitude3))
    Facilities.append(x)
    node_f3 = ox.distance.nearest_nodes(G, longitude3, latitude3)

    #Loading Map #center_point = (28.645307, 77.224662)
    center_point = (latitude, longitude)
    m1 = leafmap.Map(center=center_point, zoom=16)
    #distance = int(input("Enter the radial distance of data to be loaded: (eg - 4000)"))
    distance = 500
    G = ox.graph_from_point(center_point, dist=distance, network_type='all')
    nodes, edges1 = ox.graph_to_gdfs(G)
    node_osmid_list = [node[0] for node in G.nodes(data=True)]

    #Nearest Finder ##Need to make 3 places or multiple places logic here
    def shortest_length(node1_id, node2_id):
        try:
            shortest_path = ox.routing.shortest_path(G, node1_id, node2_id, weight="length")
            gdf = ox.routing.route_to_gdf(G, shortest_path)
            length = gdf["length"].sum()
            if length < 100:
                length = 100

        #It is the case when node1_id = node2_id
        except ValueError as e:
            if str(e) == "Graph contains no edges":
                length = 0
            else:
                raise e

        return(length)

    y1 = int(shortest_length(node_f1, node_f2))
    y2 = int(shortest_length(node_f1, node_f3))
    y3 = int(shortest_length(node_f2, node_f3))
    d1 = max(y1,y2,y3)
    d2 = int(d1/2)
    distance_common = d2
    #distance_common = 300
    print("Mid distance calculated:", distance_common)
    # Finding the radius of both facilities
    #radius_of_interest_meters = 250

    # Facility 1
    #Region of interest around the warehouse
    #area_of_interest = ee.Geometry.Point([latitude1, longitude1]).buffer(radius_of_interest_meters)
    #Map.addLayer(area_of_interest, {'color': 'green'}, 'ROI1', True, 0.8)
    #Map.centerObject(area_of_interest, 12)
    #
    # Extract street network
    center_point1 = (latitude1, longitude1)
    G1 = ox.graph_from_point(center_point1, dist = distance_common, network_type='all')
    nodes, edges = ox.graph_to_gdfs(G1)
    node_osmid_list1 = [node[0] for node in G1.nodes(data=True)]

    # Facility 2
    #Region of interest around the warehouse
    #area_of_interest2 = ee.Geometry.Point([latitude2, longitude2]).buffer(radius_of_interest_meters)
    #Map.addLayer(area_of_interest2, {'color': 'red'}, 'ROI2', True, 0.8)
    #Map.centerObject(area_of_interest2, 12)

    # Extract street network
    center_point2 = (latitude2, longitude2)
    G2 = ox.graph_from_point(center_point2, dist = distance_common, network_type='all')
    nodes, edges = ox.graph_to_gdfs(G2)
    node_osmid_list2 = [node[0] for node in G2.nodes(data=True)]

    # Extract street network
    center_point3 = (latitude3, longitude3)
    G3 = ox.graph_from_point(center_point3, dist = distance_common, network_type='all')
    nodes, edges = ox.graph_to_gdfs(G3)
    node_osmid_list3 = [node[0] for node in G3.nodes(data=True)]


    node1 = []
    node2 = []
    node3 = []
    common_nodes1 = []
    common_nodes2 = []
    common_nodes3 = []
    common_nodes_all = []

    #Building Final lists
    for i in node_osmid_list1:
        if i in node_osmid_list:
            if not i in node_osmid_list2:
                if not i in node_osmid_list3:
                    node1.append(i)
                else:
                    common_nodes1.append(i)
            else:
                common_nodes1.append(i)

    for j in node_osmid_list2:
        if j in node_osmid_list:
            if not j in node_osmid_list1:
                if not j in node_osmid_list3:
                    node2.append(j)
                else:
                    common_nodes2.append(j)
            else:
                common_nodes2.append(j)

    for l in node_osmid_list3:
        if l in node_osmid_list:
            if not l in node_osmid_list1:
                if not l in node_osmid_list2:
                    node3.append(l)
                else:
                    common_nodes3.append(l)
            else:
                common_nodes3.append(l)

    #Common List
    for c1 in common_nodes1:
        if c1 not in common_nodes_all:
            common_nodes_all.append(c1)
            
    for c2 in common_nodes2:
        if c2 not in common_nodes_all:
            common_nodes_all.append(c2)

    for c3 in common_nodes3:
        if c3 not in common_nodes_all:
            common_nodes_all.append(c3)

    st.write("Total Number of Overlapping Nodes:",len(common_nodes_all))

    common_nodes_all_added = []
    common_nodes_all_left = []

    #print("\n Common Overlaping Nodes:",common_nodes_all,"\n Nodes covered by Facility 1:",node1,"\n Nodes covered by Facility 2:",node2,"\n Nodes covered by Facility 3:",node3)

    st.write("Starting to find the nearest facility to overlapping nodes...")

    for k in common_nodes_all:
        l1 = shortest_length(node_f1, k)
        l2 = shortest_length(node_f2, k)
        l3 = shortest_length(node_f3, k)
        #print(l1, l2, l3)
        lowest_number = min(l1, l2, l3)
        if lowest_number == l1:
            common_nodes_all_added.append(k)
            node1.append(k)
            #print("Added to lone")
        elif lowest_number == l2:
            common_nodes_all_added.append(k)
            node2.append(k)
            #print("Added to ltwo")
        else:
            common_nodes_all_added.append(k)
            node3.append(k)
            #print("Added to lthree")

    for m in common_nodes_all:
        if m not in common_nodes_all_added:
            common_nodes_all_left.append(m)

    print("Overlapping nodes still left:", common_nodes_all_left)



    with open('coordinates.csv', 'w', newline='') as csvfile:
        fieldnames = ['latitude', 'longitude']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for coord in Facilities:
            writer.writerow({'latitude': coord[1], 'longitude': coord[0]})

    node_coords1 = [(G1.nodes[node_id]['x'], G1.nodes[node_id]['y']) for node_id in node1]
    with open('coordinates1.csv', 'w', newline='') as csvfile:
        fieldnames = ['latitude', 'longitude']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        # Write the header row
        writer.writeheader()
        # Write the data rows
        for coord in node_coords1:
            writer.writerow({'latitude': coord[1], 'longitude': coord[0]})

    node_coords2 = [(G2.nodes[node_id]['x'], G2.nodes[node_id]['y']) for node_id in node2]
    with open('coordinates2.csv', 'w', newline='') as csvfile:
        fieldnames = ['latitude', 'longitude']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        # Write the header row
        writer.writeheader()
        # Write the data rows
        for coord in node_coords2:
            writer.writerow({'latitude': coord[1], 'longitude': coord[0]})

    node_coords3 = [(G3.nodes[node_id]['x'], G3.nodes[node_id]['y']) for node_id in node3]
    with open('coordinates3.csv', 'w', newline='') as csvfile:
        fieldnames = ['latitude', 'longitude']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        # Write the header row
        writer.writeheader()
        # Write the data rows
        for coord in node_coords3:
            writer.writerow({'latitude': coord[1], 'longitude': coord[0]})

    #node_coords3 = [(G2.nodes[node_id]['x'], G2.nodes[node_id]['y']) for node_id in common_nodes1]
    #with open('coordinates3.csv', 'w', newline='') as csvfile:
        #fieldnames = ['latitude', 'longitude']
        #writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        # Write the header row
        #writer.writeheader()
        # Write the data rows
        #for coord in node_coords3:
            #writer.writerow({'latitude': coord[1], 'longitude': coord[0]})

    data = "coordinates.csv"
    data1 = "coordinates1.csv"
    data2 = "coordinates2.csv"
    data3 = "coordinates3.csv"

    m1.add_points_from_xy(data, x="longitude", y="latitude")

    m1.add_gdf(edges1, layer_name="Edges")

    m1.add_circle_markers_from_xy(data1, x="longitude", y="latitude", radius=10, color="green", fill_color="green")

    m1.add_circle_markers_from_xy(data2, x="longitude", y="latitude", radius=10, color="red", fill_color="red")

    m1.add_circle_markers_from_xy(data3, x="longitude", y="latitude", radius=10, color="yellow", fill_color="yellow")

    folium_static(m1)
    #m1.to_streamlit()
    st.write("Done")
    #st.map(m1)
    


# Importing all necessary libraries and modules
import ee
#import geemap
import osmnx as ox
import geopandas as gpd
import geojson


# Triggering the authentication flow for Earth Engine (Used for open source satellite datasets)
ee.Authenticate()

# Initialize the library for resources
ee.Initialize(project='egovfoundations-sg')

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Defining Functions
def goal1():
    #m = geemap.Map()
    #m.add_basemap("OpenTopoMap")
    #m.to_streamlit(height=500)

    ward = "Lajpat Nagar"
    st.write("Selecte Ward is:",ward)
    st.write("Starting...")
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
    st.write("Number of Building Detected:",count.getInfo())

    # Roads Network
    roi_roads1 = DelhiRoads2.filter(ee.Filter.bounds(roi_ward))
    Map.addLayer(roi_roads1,{'color': 'blue'}, 'Delhi Roads', True, 0.6)

    # Calculating Area of ROI
    roi_area = roi_ward.geometry().area()
    roi_area_sqkm = ee.Number(roi_area).divide(1e6)
    st.write("Area of the Ward is: (in Sq Km)",roi_area_sqkm.getInfo())

    # Displaying the interactive maps with all the features
    #scale = Map.getScale() * 3
    centroid = roi_ward.geometry().centroid()
    Map.centerObject(centroid, 15)
    Map.to_streamlit(height=500)

def goal21():
    while True:
        opt = 0
        names_dict_lis = ["Choose","Central Warehousing Corporation","JIECANG Delhi Warehouse","Godown","Shalimar Warehouse"]
        basemap1 = st.selectbox("Choose a warehouse", names_dict_lis)

        if st.button("Select Warehouse"):
            if basemap1 == "Central Warehousing Corporation":
                opt = 1
                return(opt)

            elif basemap1 == "JIECANG Delhi Warehouse":
                opt = 2
                return(opt)

            elif basemap1 == "Godown":
                opt = 3
                return(opt)

            elif basemap1 == "Shalimar Warehouse":
                opt = 4
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

    #st.selectbox("Choose a feature", basemap_options)
    keys_list = list(names_dict.keys())

    st.write("Starting Facility:")

    #index = goal21()
    #st.write(index)
    #index = index - 1
    #fixed
    index = 2
    

    selected_name = keys_list[index]
    selected_value = names_dict[selected_name]
    st.write(f"Selected starting warehouse: {selected_name}")
    st.write(f"location: {selected_value}")
    start_name = selected_name
    start_value = selected_value

    st.write("\nDestination Facility:")
    #index1 = goal21()
    #index1 = index1 - 1
    index1 = 1

    selected_name1 = keys_list[index1]
    selected_value1 = names_dict[selected_name1]
    st.write(f"Selected destination warehouse: {selected_name1}")
    st.write(f"location: {selected_value1}")
    dest_name = selected_name1
    dest_value = selected_value1

    st.write("Shortest path between ",start_name," and ",dest_name,":")

    # Region to load
    center_point = (28.69437621403761, 77.18850262865577) #center point of delhi
    G = ox.graph_from_point(center_point, dist=4500, network_type='all')

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
    Map.add_legend(title='Warehouses', legend_dict=legend_dict, position='bottomleft')

    # Adding markers for the warehouses
    point_feature = ee.Feature(ee.Geometry.Point(kzh_lon, kzh_lat), {'label': 'Start_Point'})
    point_fc = ee.FeatureCollection([point_feature])
    Map.add_layer(point_fc, {'color': 'red', 'radius': 20, 'fillColor': 'red'}, 'Start_Point')

    point_feature1 = ee.Feature(ee.Geometry.Point(mdcl_lon, mdcl_lat), {'label': 'Dest_Point'})
    point_fc1 = ee.FeatureCollection([point_feature1])
    Map.add_layer(point_fc1, {'color': 'blue', 'radius': 20, 'fillColor': 'blue'}, 'Dest_Point')

    #display(Map)
    Map.to_streamlit(height=500)

def goal3():
    # Warehouses data
    names_dict = {
        "Central Warehousing Corporation":"28.69437621403761,77.18850262865577",
        "JIECANG Delhi Warehouse":"28.70036585373791,77.16559231291417",
        "Godown":"28.6555777067871,77.23088934737488",
        "Shalimar Warehouse":"28.68086031003555,77.14947760145868"
    }

    keys_list = list(names_dict.keys())

    #index = goal21()
    #index = index - 1
    index = 1

    selected_name = keys_list[index]
    selected_value = names_dict[selected_name]
    st.write(f"Selected Warehouse: {selected_name}")
    st.write(f"location: {selected_value}")
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
    Map.addLayer(area_of_interest, {'color': 'green'}, 'ROI1', True, 0.8)
    Map.centerObject(area_of_interest, 12)

    # Extract street network
    center_point = (poi_longitude, poi_latitude)
    G = ox.graph_from_point(center_point, dist=1200, network_type='all')
    global nodes
    nodes, edges = ox.graph_to_gdfs(G)
    print(nodes)

    # Add street network as a GeoPandas layer
    Map.add_gdf(edges, layer_name='Streets')
    #display(Map)
    Map.to_streamlit(height=500)
    

    #node_list = [291542748, 458640659, 458640708]
    # Get the coordinates of the nodes
    #node_coords = [(G.nodes[node_id]['x'], G.nodes[node_id]['y']) for node_id in node_list]
    # Create a GeoJSON feature collection
    #features = [geojson.Feature(geometry=geojson.Point(coord), properties={}) for coord in node_coords]
    #feature_collection = geojson.FeatureCollection(features)


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
def main():
    st.set_page_config(layout="wide")

    st.logo("https://codeforgovtech.in/wp-content/uploads/2024/01/logo.webp", size="large")
    # Customize the sidebar
    markdown = """
    Github Issue Ticket: <https://github.com/egovernments/Digit-Core/issues/373>\n
    Github Profile: <https://github.com/SGCODEX>
    """

    st.sidebar.title("About")
    st.sidebar.info(markdown)
    logo = "https://i.imgur.com/UbOXYAU.png"
    st.sidebar.image(logo)

    # Customize page title
    st.title("OPEN SOURCE GIS TOOL")
    st.write("Developed in Dedicated Mentorship Program - Code 4 Gov Tech under eGovernment Foundations.")
    st.write("The Open Source GIS Tool aims to develop a user-friendly and accessible GIS tool to help users use geospatial information and geographic data to solve real-world problems. The tool will empower urban planners, engineers, policymakers, and community stakeholders to identify suitable locations for various projects.")
    basemap_options = ["1) Interactive GIS Tool", "2) Shortest distance between two facilities", "3) Area covered / serviced by a facility", "4) Which facility serves what area"]
    basemap = st.selectbox("Choose a feature", basemap_options)
    
    if st.button("Run"):
        if basemap == "1) Interactive GIS Tool":
            st.write("Loading Interactive Map with multiple feature levels...")
            goal1()

        elif basemap == "2) Shortest distance between two facilities":
            st.write("Loading shortest distance feature...")
            goal2()

        elif basemap == "3) Area covered / serviced by a facility":
            st.write("Loading area served feature....")
            goal3()

        elif basemap == "4) Which facility serves what area":
            st.write("Loading - Find which facility serves what area in a given map - feature...")
            facility_area_served()

if __name__ == "__main__":
    main()