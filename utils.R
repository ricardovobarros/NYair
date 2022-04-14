generate_monmap = function(data, pollutant,...){
  
  # # temp code
  # pollutant = "Carbon monoxide"
  # print(unique(data$parameter_name))
  
  # create data frame with the lat, lon, and pop-up info 
  df_tmp = data %>% filter(parameter_name==pollutant) %>% 
    subset(select=-c(date_local, parameter_name, concentration)) %>% 
    group_by(site_num) %>% summarise(lat = mean(latitude), lon = mean(longitude))
  
  
  # new column wiht html img and text
  df_tmp$pop =  paste0(
    "<img src='https://raw.githubusercontent.com/ricardovobarros/NYair/main/img/",
    pollutant,
    "/",
    df_tmp$site_num,
    "_",pollutant,".jpeg",
    "' />"
  )
    
    
    # paste0( "<img src='C:/Users/ricar/nyair/img/co/",
    # df_tmp$site_num,
    # "_co.jpeg", "' />")
    # #paste0("something here")
  


  
  map = leaflet(data=df_tmp, width = "100%", height = "100%") %>%
    addProviderTiles(providers$Stamen.Toner,
                     options = providerTileOptions(noWrap = TRUE)) %>% 
    setView(-73.93,  40.81, zoom=10) %>%
    addCircleMarkers(~lon,  ~lat, popup= ~pop)
  # map
  return(map)
}


generate_neimap = function(data, date, pollutant,...){
  # pollutant = "Carbon monoxide"
  #check paramater names
  print(unique(data$parameter_name))
  
  # SET TIME RANGE 
  start_time = date[1]
  end_time = date[2]
  
  # filter concentration of CO each site in a time period 
  df_time = data %>%   filter(parameter_name == pollutant) %>% 
    filter(date_local > start_time) %>% filter (date_local < end_time) %>%
    subset(select =-c(date_local, parameter_name, latitude, longitude)) %>% 
    group_by(site_num) %>% summarise(conc_mean = mean(concentration))
  
  # compute df sites 
  df_sites = data %>% subset(select=-c(concentration, date_local, parameter_name)) %>% 
    group_by(site_num) %>% summarise(lat= mean(latitude),lon = mean(longitude))
  
  # read geojson 
  spdf <- geojson_read("ny_nei.json",  what = "sp")
  spdf2 = fromJSON(file="ny_nei.json")
  
  # add a id to the polygons
  for(n in 1:310){
    spdf2$features[[n]][["id"]] = as.character(n)
  }
  
  # get data frame from geojson
  df_ny = spdf@data %>% subset(select=-c(boroughCode, X.id))
  
  # compute mean lon and lat and associate with each neighborhood 
  df_poly = data.frame()
  n_polygonos = length(spdf@polygons)
  for (p_n in 1:n_polygonos){
    poly_mean =  summarise(data.frame(spdf@polygons[[p_n]]@Polygons[[1]]@coords),
                           lon_mean = mean(X1),
                           lat_mean = mean(X2))[1,]
    #  add new row
    df_poly = rbind(df_poly, poly_mean)
  }
  
  # join dataframe with mean location and mean lon/lat
  df_ny = cbind(df_ny, df_poly)
  
  # create id for each polygon 
  df_ny$id = 1:length(df_ny$borough)
  
  # compute distance from every site to neighborhoods centers
  n_sites = length(df_sites$site_num)
  n_centers = length(df_ny$id)
  for (j in 1:n_sites) {
    dist_save = vector()
    for (k in 1:n_centers) {
      dist_site = distm(c(df_ny$lon_mean[k], df_ny$lat_mean[k]),
                        c(df_sites[[j, "lon"]], df_sites[[j, "lat"]]),
                        fun = distHaversine)
      dist_save = append(dist_save, dist_site)
      
    }
    col_name = df_sites$site_num[[j]]
    df_ny = cbind(df_ny, dist_save)
    df_ny = rename(df_ny, !!col_name := dist_save)
  }


  # filter mean co concentration in the time slot
  df_ny_time = df_ny %>% subset(select=c(df_time$site_num))
  
  # compute weight matrix
  weight = compute_weight2(df_ny_time,l=100, dist_limit = 500) 
  
  # compute concentrations everywhere 
  all_con = data.frame(data.matrix(weight)%*%df_time$conc_mean/rowSums(weight))
  colnames(all_con) = "conc"
  
  
  # add ids to all concentrations
  all_con$ID = as.character(1:310)
  
  # choropleth map 
  nearst = format(round(apply(df_ny_time[,-1], 1, min)/1000, 2), nsmall=2)
  map_pol <- plot_ly()
  map_pol <- map_pol %>% add_trace(
    text=paste(df_ny$neighborhood,
               paste0("nearst monitor:", nearst," [km]"),
               sep="<br>"),
    type="choroplethmapbox",
    showlegend = TRUE,
    geojson=spdf2,
    locations=all_con$ID,
    z=format(round(all_con$conc, 2), nsmall=2),
    colorscale= "RdYIGn", #"Viridis",
    zmin=0,
    zmax=format(round(max(all_con$conc), 2), nsmall=2),
    marker=list(line=list(
      width=0),
      opacity=0.5
    )
  )
  
  # create layout 
  map_pol <-
    map_pol %>% layout(
      mapbox = list(
        style = "carto-positron",
        zoom = 9,
        center = list(lon = -73.9, lat = 40.8)
      )
    ) %>%  config(displayModeBar = F)

  return(map_pol)
}

# compute fuzzy weight matrix 
compute_weight2 <- function(d, l = 500, dist_limit = 500) {
  if (d < dist_limit) {
    return(1)
  } else{
    return(exp((d / l) * log(0.5, base = exp(1))))
  }
  
}

parameter_to_key = function(data){
  data["parameter_name"][data["parameter_name"] == "Nitrogen dioxide (NO2)"] = "no2"
  data["parameter_name"][data["parameter_name"] == "Carbon monoxide"] = "co"
  data["parameter_name"][data["parameter_name"] == "Ozone"] = "o3"
  data["parameter_name"][data["parameter_name"] == "Sulfur dioxide"] = "so2"
  return(data)
}