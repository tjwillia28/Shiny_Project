shinyUI(
  dashboardPage( skin = 'green',
    dashboardHeader(title = 'US National Parks'),
    dashboardSidebar(
      sidebarMenu(
        menuItem('Select a Species', tabName = 'species_tab'),
        menuItem('Select a Park', tabName = 'park_tab'),
        menuItem('Compare Parks', tabName = 'park_comparison_tab')
        
      ),
      selectInput(inputId = 'species_selection', 
                     label = 'Select a species', 
                     choices =(c('Moose', 'Coyote', 
                                 'Canyon Grape', 'Harlequin Duck',
                                 'Hoary Bat', 'Bald Eagle',
                                 'Thread Rush', 'Argentine Ant',
                                 'Lynx', 'Wolverine',
                                 'Blooming Sally', 'Gulf Pipefish',
                                 'Guppy', 'Haha', 'Jelly Cup',
                               'Lake Chub', 'Lake Trout',
                               'Southern Flying Squirrel',
                               'Spotted Sandpiper', 'Virginia Rail',
                               'Wandering Tattler', 'Yellow Warbler'))),
      selectInput(inputId = 'park_selection',
                  label = 'Select a park',
                  choices = unique(df_ps$Park.Name)),
      selectInput(inputId = 'park_metric_selection',
                  label = 'Select a park comparison metric',
                  choices = c('Species Richness',
                              'Species Density',
                              'Total Acreage',
                              'Number of Endangered Species')),
      selectInput(inputId = 'category_selection',
                  label = 'Select a category',
                  choices = unique(df_ps$Category))
      
      
    ),
    dashboardBody(
      tabItems(
      #Species Tab Layout
      tabItem( tabName = 'species_tab',
              fluidRow(
                infoBoxOutput('common_name_box'),
                infoBoxOutput('scientific_name_box'),
                infoBoxOutput('conservation_status_box')),
              fluidRow(
                box(leafletOutput('base_map'), height = '100%', width = '100%'))),
      
      #Park Tab Layout
      tabItem( tabName = 'park_tab',
              fluidRow( 
                infoBoxOutput('park_name_box'),
                infoBoxOutput('acres_in_park_box')),
              fluidRow(
                infoBoxOutput('species_richness_box'),
                infoBoxOutput('species_density_box')),
              fluidRow(
                htmlOutput('park_category_species_bar_plot'))),
      
      # Park Comparison Tab Layout
      tabItem( tabName = 'park_comparison_tab',
               fluidRow(
                 valueBoxOutput('category_box', width = '100%')),
               fluidRow(
                htmlOutput('googlevis_category_plot')),
               br(),
               fluidRow(
                 valueBoxOutput('park_comparison_box', width = '100%')),
               fluidRow(
                htmlOutput('googlevis_plot_metric'))
               )
      )
      )
      )
  
    )

