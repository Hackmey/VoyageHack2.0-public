from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain import LLMChain, PromptTemplate
from langchain.memory import ConversationBufferMemory
# import ollama
import requests
import re
from datetime import datetime,timedelta
from langchain_community.llms import Ollama
from collections import defaultdict
import json




app = FastAPI()

# Company API endpoints
SIGHTSEEING_API = "https://SightseeingBE.tektravels.com/SightseeingService.svc/rest/Search"  # Replace with actual endpoint

# Define the memory for the chatbot
memory = ConversationBufferMemory()

# Define the prompt template for the chatbot
prompt_template = PromptTemplate(
    input_variables=["history", "input"],
    template="""
    You are a helpful travel assistant. You help users create itineraries for their trips.
    Previous conversation:
    {history}

    User: {input}
    Assistant:
    """
)
llm = Ollama(model="llama2")  # Use the desired model, e.g., "llama2"

# Initialize the LLMChain
llm_chain = LLMChain(
    llm=llm,
    prompt=prompt_template,
    memory=memory
)

# Define the request model
class ChatRequest(BaseModel):
    message: str

# Define the response model
class ChatResponse(BaseModel):
    response: str

@app.post("/chat", response_model=ChatResponse)
async def chat(chat_request: ChatRequest):
    user_message = chat_request.message

    # Check if the user is asking for an itinerary
    if "itinerary" in user_message.lower() or "plan" in user_message.lower():
        # Extract details from the user's message
        details = extract_travel_details(user_message)
        # print("Extracted Details:", details)


        if details:
            print(f"Extracted details :{details}")
            city = details["city"]
            country_code = get_country_code(city)  # Map city to country code
            travel_start_date = details["start_date"]
            travel_end_date = details["end_date"]
            adult_count = details["adults"]
            child_count = details["children"]

            # Fetch sightseeing information
            sightseeing_info = fetch_sightseeing_info(
                city_id=get_city_id(city),  # Map city to city ID
                country_code=country_code,
                # travel_start_date=travel_start_date,
                from_date=travel_start_date,
                to_date=travel_end_date,
                adult_count=adult_count,
                child_count=child_count,
                child_age="",  # Optional: Extract child ages if mentioned
                preferred_language=0,
                preferred_currency="INR",
                is_base_currency_required=False,
                booking_mode=5,
                end_user_ip="xxx.xxx.xxx.xx",  # Replace with actual IP
                token_id="127d1b83-c347-43e6-becd-48cae0912af7",  # Replace with actual token
                keyword=""  # Optional
            )
            print("API Response:", sightseeing_info)

            # Generate the itinerary
            itinerary = generate_itinerary(sightseeing_info, travel_start_date, travel_end_date)

            # Add the itinerary to the memory
            memory.chat_memory.add_user_message(user_message)
            memory.chat_memory.add_ai_message(itinerary)

            return ChatResponse(response=itinerary)
        else:
            return ChatResponse(response="Please provide all necessary details for the itinerary.")
    else:
        # If it's not an itinerary request, just respond normally
        response = llm_chain.run(user_message)
        return ChatResponse(response=response)

def extract_travel_details(message: str) -> dict:
    # Extract city
    city_match = re.search(r"for ([A-Za-z\s]+)", message, re.IGNORECASE)
    city = city_match.group(1).strip() if city_match else None

    # Extract dates
    date_pattern = r"(\d{1,2})(?:th|st|nd|rd)?(?: of)?\s+(January|February|March|April|May|June|July|August|September|October|November|December)"
    date_matches = re.findall(date_pattern, message, re.IGNORECASE)
    start_date, end_date = None, None


    if len(date_matches) >= 2:
        start_date = parse_date(f"{date_matches[0][0]} {date_matches[0][1]}")
        end_date = parse_date(f"{date_matches[1][0]} {date_matches[1][1]}")

    # Extract number of adults and children
    adults_match = re.search(r"(\d+)\s+adults?", message, re.IGNORECASE)
    children_match = re.search(r"(\d+)\s+children?", message, re.IGNORECASE)
    adults = int(adults_match.group(1)) if adults_match else 0
    children = int(children_match.group(1)) if children_match else 0

    print("Extracted City:", city)
    print("Extracted Start Date:", start_date)
    print("Extracted End Date:", end_date)
    print("Extracted Adults:", adults)
    print("Extracted Children:", children)

    if city and start_date and end_date and adults > 0:
        return {
            "city": city,
            "start_date": start_date,
            "end_date": end_date,
            "adults": adults,
            "children": children
        }
    else:
        print("Extraction failed: Missing required fields")
        return {}


def parse_date(date_str: str) -> str:
    # Convert "5th February" -> "5 February"
    date_str = re.sub(r"(\d+)(th|st|nd|rd)", r"\1", date_str)
    if len(date_str.split()) == 2:  # If the date only has "day month"
        current_year = datetime.now().year
        date_str += f" {current_year}"

    try:
        return datetime.strptime(date_str, "%d %B %Y").strftime("%Y-%m-%d")
    except ValueError as e:
        print(f"❌ Error parsing date '{date_str}': {e}")
        return None


def get_country_code(city: str) -> str:
    # Map city to country code (replace with actual logic or API call)
    city_to_country = {
        "Paris": "FR",
        "New York": "US",
        "London": "GB",
        "Dubai": "AE"

    }
    return city_to_country.get(city, "UNKNOWN")

def get_city_id(city: str) -> str:
    # Map city to city ID (replace with actual logic or API call)
    city_to_id = {
        "Paris": "131408",
        "New York": "123456",
        "London": "789012",
        "Dubai": "115936"

    }
    if city in city_to_id:
        return city_to_id[city]
    return city_to_id.get(city, "UNKNOWN")

def fetch_sightseeing_info(**kwargs):
    # Fetch sightseeing information from the company's API
    payload = {
        "CityId": kwargs.get("city_id"),
        "CountryCode": kwargs.get("country_code"),
        # "TravelStartDate": kwargs.get("travel_start_date"),
        "FromDate": kwargs.get("from_date"),
        "ToDate": kwargs.get("to_date"),
        "AdultCount": kwargs.get("adult_count"),
        "ChildCount": kwargs.get("child_count"),
        "ChildAge": [],#kwargs.get("child_age", [2,3]),  # Optional: Extract child ages if mentioned
        "PreferredLanguage": kwargs.get("preferred_language", 0),
        "PreferredCurrency": kwargs.get("preferred_currency", "INR"),
        "IsBaseCurrencyRequired": kwargs.get("is_base_currency_required", False),
        "BookingMode": kwargs.get("booking_mode", 5),
        "EndUserIp": "192.168.5.56",  # Replace with actual IP
        "TokenId": "127d1b83-c347-43e6-becd-48cae0912af7",  # Replace with actual token
        "KeyWord": kwargs.get("keyword", "")  # Optional
    }
    print("🔹 Sending API Request:", payload)
    response = requests.post(SIGHTSEEING_API, json=payload)

    if response.status_code == 200:
        data = response.json()
        if data.get("Response", {}).get("ResponseStatus") != 1:
            print(f"⚠️ API Error: {data}")
            return "API Error: " + data.get("Response", {}).get("Error", {}).get("ErrorMessage", "Unknown error")
        return data  # Return full API response    else:
    else:
        print(f"❌ API Request Failed: {response.status_code}")
        return "No sightseeing information available."




# Generate multi-day itinerary
# Generate multi-day itinerary
def generate_itinerary(response, from_date, to_date):

    # Ensure response is a dictionary, not a string
    if isinstance(response, str):
        try:
            response = json.loads(response)  # Convert string to dictionary
        except json.JSONDecodeError:
            print("❌ Failed to parse response as JSON.")
            return "Error: Invalid response format from API."

    sightseeing_results = response.get("Response", {}).get("SightseeingSearchResults", [])

    if not sightseeing_results:
        return "No sightseeing activities available."

    # Convert string dates to datetime objects
    travel_start_date = datetime.strptime(from_date, "%Y-%m-%d")
    travel_end_date = datetime.strptime(to_date, "%Y-%m-%d")

    # Generate date list
    date_list = [travel_start_date + timedelta(days=i) for i in range((travel_end_date - travel_start_date).days + 1)]
    itinerary = {}

    # Distribute activities across the travel period using round-robin
    for i, date in enumerate(date_list):
        formatted_date = date.strftime("%Y-%m-%d")
        itinerary[formatted_date] = []

        # Cycle through available sightseeing activities
        activity = sightseeing_results[i % len(sightseeing_results)]

        itinerary[formatted_date].append({
            "SightseeingName": activity["SightseeingName"],
            "TourSummary": activity.get("TourSummary", "No summary available."),
            "Price": activity["Price"]["OfferedPriceRoundedOff"],
            "Currency": "INR",  # Force INR display
            "Image": activity.get("ImageList", [])[0] if activity.get("ImageList") else "No image available"
        })

    # Print base itinerary (for debugging)
    print("\n🔹 Base Itinerary:")
    print_itinerary(itinerary)

    # Generate a detailed itinerary using Ollama
    detailed_itinerary = generate_detailed_itinerary(itinerary)

    # Print detailed itinerary for debugging
    print("\n🔹 Detailed Itinerary from Ollama:")
    print(detailed_itinerary)

    return detailed_itinerary



# Generate a detailed itinerary using Ollama
def generate_detailed_itinerary(itinerary):
    ollama = Ollama(model="llama2")  # Ensure you have Ollama running locally
    itinerary_text = "\n".join([
        f"📅 {date}\n" + "\n".join([
            f"- {act['SightseeingName']} ({act['Price']} {act['Currency']}): {act['TourSummary']}"
            for act in activities])
        for date, activities in itinerary.items()])

    prompt = f"""
    You are a travel assistant. Generate a detailed travel itinerary based on the following plan:

    {itinerary_text}

    Provide a structured, engaging itinerary including best travel times, local recommendations, and cultural insights.
    """

    response = ollama(prompt)
    return response


# Print formatted itinerary
def print_itinerary(itinerary):
    for date, activities in itinerary.items():
        print(f"\n📅 {date}")
        for act in activities:
            print(f" - {act['SightseeingName']} ({act['Price']} {act['Currency']}): {act['TourSummary']}")
    return itinerary
# message= "Hey can you create an itinerary for Dubai? I am planning to start my journey on 5th of February to 15th of February with my family. We are 3 members including 1 children and 2 adults."
# detail = extract_travel_details(message)
# print(detail)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)