function(input, output, session) {
  
#============================
# Species Lookup Tab
#============================
  
#----------------
  # Base Map
#----------------
   output$base_map = renderLeaflet({
     leaflet() %>%
       addProviderTiles(providers$Esri.WorldImagery) %>%
       setView(lng = -97, lat = 35, zoom = 2)
   
     })
#----------------
  # Updating Map with user input species selection
#----------------
  
  observeEvent(input$species_selection, {
    
    x = df_ps %>% filter(., Common.Name == input$species_selection) %>%
      unique() %>%
      na.omit()
    
  
  
  leafletProxy('base_map', data = x) %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    addMarkers(lng = ~Longitude, 
               lat = ~Latitude, 
               popup = ~Park.Name,
               icon = national_park_logo,
               clusterOptions = markerClusterOptions(showCoverageOnHover = FALSE))
  
  
  })
   
#---------------
   # Tiles for Scientific Name, Number of Parks the Species is located in, Conservation Status, Nativeness
#---------------
   #--------
   # Reactive fxn to return Common Name
   Common_Name_ = reactive({
     common_name = input$species_selection
   })
   # Common Name Box
   output$common_name_box <- renderInfoBox({
     infoBox('Common Name', Common_Name_(), color = 'black')
   })
   
   #-------
   # Reactive fxn to lookup Scientific Name
   Scientific_Name_ = reactive({
     scientific_name = df_ps %>% filter(., Common.Name == input$species_selection) %>% summarise(., first(Scientific.Name))
   })
   
   # Scientific Name Box 
   output$scientific_name_box <- renderInfoBox({
     infoBox('Scientific Name', Scientific_Name_(), color = 'green')
   })
   #-------
   # Reactive fxn to lookup Conservation Status
   Conservation_Status_ = reactive({
     conservation_status = df_ps %>% filter(., Common.Name == input$species_selection) %>% summarise(., first(Conservation.Status))
     
   })
   
   #Conservation Status Box
   output$conservation_status_box <- renderInfoBox({
     infoBox('Conservation Status', Conservation_Status_(), color = 'black')
   })
   #-------

#==============================
   # Park Lookup Tab
#==============================
   #---------
   # Tiles for Park Name, Acres, Species Richness and Species Diversity
   #---------
   
   #-------
   # Reactive fxn to return Park Name
   Park_Name_ = reactive({
     park_name = input$park_selection
   })
   
   # Park Name Box
   output$park_name_box <- renderInfoBox({
     infoBox('Park Name', Park_Name_(), color = 'black')
   })
   
   #----------
   #Reactive fxn to return total acres in selected park
   Acres_In_Park_ = reactive({
     acres_in_park = df_ps %>% filter(., Park.Name == input$park_selection) %>% summarise(., first(Acres))
   })
   
   # Acres in Park Box
   output$acres_in_park_box <- renderInfoBox({
     infoBox('Acres in Park', Acres_In_Park_(), color = 'green')
   })
   
   #-----------
   # Reactive fxn to output species richness for selected park
   Species_Richness_ = reactive({
     species_richness = df_ps %>% filter(., Park.Name == input$park_selection) %>% unique() %>% na.omit() %>% summarise(., n())
   })
   
   # Species Richness Box
   output$species_richness_box <- renderInfoBox({
     infoBox('Species Richness', Species_Richness_(), color = 'green')
   })
   
   #--------------
   # Reactive function to calculate Species Density
   Species_Density_ = reactive({
     species_density = (df_ps %>% filter(., Park.Name == input$park_selection) %>% unique() %>% na.omit() %>% summarise(., n()))/(df_ps %>% filter(., Park.Name == input$park_selection) %>% summarise(., first(Acres))) 
   })
   
   # Species Density Box
   output$species_density_box <- renderInfoBox({
     infoBox('Species Density', Species_Density_(), color = 'black')
   })
   
   #------------
   # Bar Graph Measuring showing number of species in each category for  each park
   #------------
   
   output$park_category_species_bar_plot <- renderGvis({
     
     # Number of species in a category for a specific park
     plot_data_1 = df_ps %>% filter(., Park.Name == input$park_selection) %>%
       group_by(., Category) %>%
       summarise(., Species = n()) %>%
       arrange(., desc(Species))
  
     gvisColumnChart(plot_data_1, options = list(
       series="[{color:'black'}]", legend = 'none', vAxis="{title:'Number of Species'}",
       hAxis="{title:'Category'}"))
     
      })
   #=========================
   # Park Comparison Tab
   #=========================
   
   #-------------
   # Tile for Comparison Metric, Category
   #-------------
   
   # Reactive Funciton to show metric selection
   Comparison_Metric_ = reactive({
     comparison_metric = input$park_metric_selection
   })
   
   # Comparison Metric Box
   output$park_comparison_box <- renderValueBox({
     valueBox(Comparison_Metric_(), 'Metric', color = 'black')
   })
   
   #Reactive Function to show Category selection
   Category_ = reactive({
     category_ = input$category_selection
   })
   
   # Category Box
   output$category_box <- renderValueBox({
     valueBox(Category_(), 'Category', color = 'black')
   })
   
   #---------------
   # Plot of Number of Species in selected category
   #---------------
   
   output$googlevis_category_plot <- renderGvis({
     
     # Number of species in a category for each park
     
     
     plot_data_2 = df_ps %>% filter(., Category == input$category_selection) %>% 
       group_by(., Park.Name) %>%
       summarise(., Species = n()) %>%
       arrange(desc(Species))
  
     
     gvisColumnChart(head(plot_data_2, 15), options = list(
       series="[{color:'green'}]", legend = 'none', hAxis="{title:'Park'}", vAxis="{title:'Number of Species'}" ))
   
   })
   
   #-------------------
   # Dataframe filtering and plot for comparison metrics and GoogleVis plot for metrics
   #------------------
   output$googlevis_plot_metric <- renderGvis({
     
     if (input$park_metric_selection == 'Species Richness'){
       
       plot_data_3 = df_ps %>% na.omit() %>% group_by(., Park.Name) %>%
        summarise(., Species_Richness = n()) %>% 
         arrange(., desc(Species_Richness))
       
     } else if (input$park_metric_selection == 'Species Density') {
       
       plot_data_3 = df_ps %>% na.omit() %>% group_by(., Park.Name) %>%
         unique() %>%
         summarise(., Species_Density = n()/first(Acres)) %>% 
         arrange(., desc(Species_Density))
       
     } else if (input$park_metric_selection == 'Total Acreage') {
       
       plot_data_3 = df_ps %>% na.omit() %>% group_by(., Park.Name) %>%
         summarise(., Total_Acres = first(Acres)) %>%
         arrange(., desc(Total_Acres))
       
     } else if (input$park_metric_selection == 'Number of Endangered Species'){
       
       plot_data_3 = df_ps %>% filter(., Conservation.Status == 'Endangered') %>%
         na.omit() %>% group_by(., Park.Name) %>%
         summarise(., Endangered_Species = n()) %>%
         arrange(., desc(Endangered_Species))
     }
    
     
     gvisColumnChart(head(plot_data_3, 15), options = list(
       series="[{color:'green'}]", legend = 'none', hAxis="{title:'Park'}")) 
     
   })
   
   
   
   }
