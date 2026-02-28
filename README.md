# Bitespeed Identity Reconciliation Service

A backend service that identifies and links customer contact information across multiple purchases.

## 🚀 Live Demo

**API Endpoint:** `https://bitespeed-identity-sbeu.onrender.com/identify`

**Health Check:** `https://bitespeed-identity-sbeu.onrender.com/health`

## 📋 API Documentation

### POST /identify

Identifies and consolidates customer contact information.

#### Request Format
```json
{
  "email": "example@email.com",
  "phoneNumber": "1234567890"
}
```

**Note:** At least one of `email` or `phoneNumber` must be provided.

#### Response Format
```json
{
  "contact": {
    "primaryContatctId": 1,
    "emails": ["primary@email.com", "secondary@email.com"],
    "phoneNumbers": ["1111111", "2222222"],
    "secondaryContactIds": [2, 3]
  }
}
```

## 🧪 Example Requests

### Create New Contact
```bash
curl -X POST https://bitespeed-identity-sbeu.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"lorraine@hillvalley.edu","phoneNumber":"123456"}'
```

**Response:**
```json
{
  "contact": {
    "primaryContatctId": 1,
    "emails": ["lorraine@hillvalley.edu"],
    "phoneNumbers": ["123456"],
    "secondaryContactIds": []
  }
}
```

### Link Contacts with Common Information
```bash
curl -X POST https://bitespeed-identity-sbeu.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"mcfly@hillvalley.edu","phoneNumber":"123456"}'
```

**Response:**
```json
{
  "contact": {
    "primaryContatctId": 1,
    "emails": ["lorraine@hillvalley.edu", "mcfly@hillvalley.edu"],
    "phoneNumbers": ["123456"],
    "secondaryContactIds": [2]
  }
}
```

### Query with Only Email
```bash
curl -X POST https://bitespeed-identity-sbeu.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"lorraine@hillvalley.edu"}'
```

### Link Two Primary Contacts
```bash
# Create first primary
curl -X POST https://bitespeed-identity-sbeu.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"george@hillvalley.edu","phoneNumber":"919191"}'

# Create second primary
curl -X POST https://bitespeed-identity-sbeu.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"biffsucks@hillvalley.edu","phoneNumber":"717171"}'

# Link them together
curl -X POST https://bitespeed-identity-sbeu.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"george@hillvalley.edu","phoneNumber":"717171"}'
```

**Response:**
```json
{
  "contact": {
    "primaryContatctId": 3,
    "emails": ["george@hillvalley.edu", "biffsucks@hillvalley.edu"],
    "phoneNumbers": ["919191", "717171"],
    "secondaryContactIds": [4]
  }
}
```

## 🛠️ Technology Stack

- **Backend Framework:** Node.js with Express
- **Language:** TypeScript
- **Database:** SQLite
- **ORM:** Prisma
- **Deployment:** Render.com

## 💻 Local Development

### Prerequisites
- Node.js 20+
- npm

### Setup

1. Clone the repository
```bash
git clone https://github.com/KrishnaGhetia/bitespeed-identity.git
cd bitespeed-identity
```

2. Install dependencies
```bash
npm install
```

3. Set up environment variables
```bash
echo 'DATABASE_URL="file:./dev.db"' > .env
echo 'PORT=3000' >> .env
```

4. Run database migrations
```bash
npx prisma migrate dev --name init
```

5. Start development server
```bash
npm run dev
```

The server will run at `http://localhost:3000`

### Testing Locally
```bash
curl -X POST http://localhost:3000/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","phoneNumber":"1234567890"}'
```

## 📂 Project Structure
```
bitespeed-identity/
├── src/
│   ├── index.ts              # Express server setup
│   ├── routes/
│   │   └── identify.ts       # /identify endpoint
│   ├── services/
│   │   └── contactService.ts # Business logic
│   └── types/
│       └── index.ts          # TypeScript interfaces
├── prisma/
│   ├── schema.prisma         # Database schema
│   └── migrations/           # Database migrations
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript configuration
├── .env.example              # Environment variables template
└── README.md                 # Documentation
```

## 🔧 How It Works

The service maintains a `Contact` table with the following structure:
```typescript
{
  id: number
  phoneNumber: string | null
  email: string | null
  linkedId: number | null
  linkPrecedence: "primary" | "secondary"
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime | null
}
```

### Key Features:

1. **Contact Linking:** Contacts are linked if they share either email or phone number
2. **Primary/Secondary Hierarchy:** The oldest contact becomes "primary", others become "secondary"
3. **Automatic Consolidation:** When two separate primary contacts are linked, the newer one automatically becomes secondary
4. **Comprehensive Response:** Returns all emails, phone numbers, and secondary contact IDs associated with a customer

### Algorithm Overview:

1. **Search for existing contacts** matching the provided email or phone number
2. **If no matches found:** Create a new primary contact
3. **If matches found:** 
   - Identify the primary contact (oldest one)
   - Check if request contains new information
   - Create secondary contact if needed
4. **If multiple primaries found:** 
   - Keep the oldest as primary
   - Convert newer one(s) to secondary
5. **Return consolidated response** with all linked contact information

## 📝 API Requirements

- ✅ Accepts JSON request body (not form-data)
- ✅ Returns JSON response
- ✅ Links contacts by email or phone number
- ✅ Maintains primary/secondary relationships
- ✅ Handles primary-to-secondary conversions


## ⚠️ Notes

- Using SQLite for simplicity
- On Render's free tier, the app sleeps after 15 minutes of inactivity
- First request after sleep may take 30-60 seconds (cold start)
- For production use, consider migrating to PostgreSQL


## 👤 Author

Krishna Ghetia