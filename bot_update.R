
library("R6")
library("websocket")
library("bitops")
library("jsonlite")
library("later")
library("logging")
library("magrittr")
library("purrr")
library("methods")
library('httr')

# source("gdrive.R")

source("https://raw.githubusercontent.com/favstats/discordr/master/R/logging.R")
source("https://raw.githubusercontent.com/favstats/discordr/master/R/rest-api-tools.R")
source("https://raw.githubusercontent.com/favstats/discordr/master/R/websocket.R")



# source("utils.R")

# print(Sys.getenv(r_discord_bot_django))

bot <- DiscordrBot$new(token = Sys.getenv("r_discord_bot_django"))



bot$register_event_handler("MESSAGE_CREATE", function(msg){
  # avoid handling your own messages
  if (msg$author$id == "974385611161075713"){
    return()
  }
  # guard to work only in test channel
  # if (msg$channel_id != TEST_CHANNEL_ID){
  #   return()
  # }
  
  # print(msg)
  
  # print(msg$content)
  
  # yo <- "<@&974420601810853931>"
  
  if(startsWith(msg$content, "<@&974420601810853931>") | startsWith(msg$content, "<@974385611161075713>") | startsWith(msg$content, "<@&974391049118179351>")){
    
    bot_id <- paste0("<", regmatches(msg$content, gregexpr( "(?<=\\<).+?(?=\\>)", msg$content, perl = T))[[1]], ">")
    
    the_prompt <- gsub("<@974385611161075713> ", "", msg$content)
    the_prompt <- gsub("<@&974391049118179351> ", "", the_prompt)
    the_prompt <- gsub("<@&974420601810853931>" , "", the_prompt)
    
    
    if(bot_id %in% c("<@974385611161075713>",
                     "<@&974391049118179351>",
                     "<@&974420601810853931>" 
    )) {
      print(paste0(bot_id, ": ", "MATCH"))
    } else {
      print(paste0(bot_id, ": ", "FAIL"))
      cat(bot_id, file = "fail_id.txt")
    }


          
    n_tokens <- as.numeric(regmatches(the_prompt, gregexpr( "(?<=\\[).+?(?=\\])", the_prompt, perl = T))[[1]])
    
    if(length(n_tokens)==0) {
      n_tokens <- 250
    } else {
      the_prompt <- gsub(paste0(" \\[", n_tokens, "\\]"), "", the_prompt)
    }
    
    # print(the_prompt)
    
    gpt_prompt <- list(
      prompt = the_prompt,
      temperature = 1,
      max_tokens = n_tokens,
      top_p = 1,
      frequency_penalty = 0.5,
      presence_penalty = 0.5
    ) 
    
    myurl <- "https://api.openai.com/v1/engines/text-davinci-002/completions"
    
    apikey <- Sys.getenv("gpt3")
    
    output <- httr::POST(myurl, 
                         body = gpt_prompt, 
                         add_headers(Authorization = paste("Bearer", apikey)), 
                         encode = "json")
    
    
    message_to_sent <- content(output)$choices[[1]]$text
    
    # print(message_to_sent)
    
    send_message(message_to_sent, as.character(msg$channel_id), bot) 
       
  }

})


# enable_console_logging(level=10)
# enable_file_logging(level=10)

bot$start()

Sys.sleep(60*60*4.9)

bot$finalize()



# send_message("yoyoyoo", "546099563006787607", bot)



