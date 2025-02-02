# VoyageHack2.0-public
# 🌍 Swizzle

An AI-powered itinerary planner that helps users generate personalized travel plans, modify them dynamically, and integrate real-time weather updates and flight search.

## ✨ Features
- **AI-generated itineraries** based on user preferences.
- **Day-by-day customization** with reordering and modifications.
- **Real-time weather updates** for selected destinations.**(in progress)**
- **Nearby attractions suggestions** using Google Maps integration.**(partialy implemented)**
- **Dynamic memory updates** for improved user experience.
- **Flight search integration** via a TBO API.
- **Group itinerary planning** using Flutter for mobile interaction.

## 🛠️ Tech Stack
- **Frontend:** Flutter
- **Backend:** FastAPI, LangChain, Ollama
- **Database:** Firebase, MongoDB **(to be used for media storage)**
- **Third-party Integrations:** TBO APIs, Google Maps API, OpenWeather API (to be implemented i.e in progress)

## 📝 Pages Explanation
1. **Home Page**
   - Post new itineraries, search for specific trips, and explore trending itineraries from the community.
2. **Chat with the AI Bot**
   - Interact with the AI-powered chatbot to create personalized itineraries, modify existing plans, and receive travel suggestions.
3. **Community Page**
   - Create and search for communities of like-minded travelers to share experiences, tips, and recommendations.
4. **Group Chat Page**
   - Create groups and join rooms, use the bot in a shared access and plan with others.

## 🔧 Setup & Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Hackmey/VoyageHack2.0-public.git
   cd swizzle_frontend
   ```
2. Install dependencies (Flutter):
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
## System Architecture
Basic Chatting System for both group and individual chats.
![image](https://github.com/user-attachments/assets/8d5a75ed-60de-47de-8f0a-65603e2a8f61)

High-level architecture of the Swizzle Bot
![image](https://github.com/user-attachments/assets/4094fa3b-a24e-4044-b46d-de93ff08d496)



