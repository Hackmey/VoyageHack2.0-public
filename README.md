# VoyageHack2.0-public
# 🌍 Swizzle

**[VIDEO EXPLANATION]** - https://drive.google.com/file/d/1L9ef4nolkwArl9ud23-auBAhA3MFs4Gx/view

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
   cd VoyageHack2.0-public
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
**[NOTE] : While you run the app make sure that you connect an android with USB Debugger option enabled.**
**[NOTE]: TBO Auth Token may get expired after 24 hours of generating, use a newly generated auth token**

## For Chatbot Setup
1. Setup Virual environment:
   ```bash
   cd VoyageHack2.-public
   cd itinerary_gen
   pip install virtualenv
   python3 -m venv bot
   ```
   here virtual environment has been named as "bot" for further eg:
2. Activate Virtual environment:
   ```bash
   bot/Scripts/activate.bat //In CMD
   bot/Scripts/Activate.ps1 //In Powershell
   ```
If Encountered with the powershell bug: 
**cannot be loaded because running scripts is disabled on this system. For more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170**
In that case: 
- Run Windows powershell as adminstrator and run the following command
```bash 
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```
- type Y for yes, hit enter
- rerun the command and type A and hit enter
- close the powershell
- and run the above scripts to activate the virtual environment
      
3. Install dependancies:
   ```bash
   pip install -r requirements.txt
   ```

## System Architecture
Basic Chatting System for both group and individual chats.
![chat-arch](https://github.com/user-attachments/assets/6f60c3c2-9d21-4789-8bbb-2529528c5b22)


High-level architecture of the Swizzle Bot
![bot-archi](https://github.com/user-attachments/assets/657c7b9c-7421-419c-bbaf-70a99cd0a2f6)

## 📸 Screenshots
Login and Signup Page

![image](https://github.com/user-attachments/assets/5fcbe323-60d0-42db-82d2-b9cac23f6502)

Intro Page

![image](https://github.com/user-attachments/assets/63177fec-8246-4836-997e-340390566435)

Home Page & Itinerary Page

![image](https://github.com/user-attachments/assets/7dcff2b2-79ac-4c72-b5a1-5e2155568e68)


Swizzle Bot

![image](https://github.com/user-attachments/assets/17fa095b-074d-4fc3-9f5f-02f90000b67d)


Community Tab

![image](https://github.com/user-attachments/assets/54045c8e-2f0b-4576-b93e-b5d032a51339)


Groups Page

![image](https://github.com/user-attachments/assets/83c6e8a3-93f1-4864-80fc-6f40109fab52)

Group Chat

![image](https://github.com/user-attachments/assets/a2029030-5a35-40af-9bb1-732fbfcddbe4)







