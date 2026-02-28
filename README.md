# Bitespeed Identity Reconciliation Service

A backend service that identifies and links customer contact information across multiple purchases.

## 🚀 Live Demo

**API Endpoint:** `https://your-app-name.onrender.com/identify`

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
curl -X POST https://your-app-name.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"lorraine@hillvalley.edu","phoneNumber":"123456"}'
```

### Link Contacts with Common Information
```bash
curl -X POST https://your-app-name.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"mcfly@hillvalley.edu","phoneNumber":"123456"}'
```

### Query with Only Email
```bash
curl -X POST https://your-app-name.onrender.com/identify \
  -H "Content-Type: application/json" \
  -d '{"email":"lorraine@hillvalley.edu"}'
```

## 🛠️ Technology Stack

- **Backend Framework:** Node.js with Express
- **Language:** TypeScript
- **Database:** SQLite (Development) 
- **ORM:** Prisma
- **Deployment:** Render.com

## 💻 Local Development

### Prerequisites
- Node.js 20+
- npm

### Setup

1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/bitespeed-identity.git
cd bitespeed-identity
```

2. Install dependencies
```bash
npm install
```

3. Set up environment variables
```bash
cp .env.example .env
# Edit .env with your database URL
```

4. Run database migrations
```bash
npx prisma migrate dev
```

5. Start development server
```bash
npm run dev
```

The server will run at `http://localhost:3000`

### Testing

Test the `/identify` endpoint:
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
│   └── schema.prisma         # Database schema
├── package.json
└── README.md
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

