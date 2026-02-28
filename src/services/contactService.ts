import { PrismaClient } from '@prisma/client';
import { IdentifyRequest, IdentifyResponse, Contact } from '../types';

const prisma = new PrismaClient();

export class ContactService {
  
  async identify(request: IdentifyRequest): Promise<IdentifyResponse> {
    const { email, phoneNumber } = request;

   
    const matchingContacts = await this.findMatchingContacts(email, phoneNumber);

   
    if (matchingContacts.length === 0) {
      const newContact = await prisma.contact.create({
        data: {
          email: email || null,
          phoneNumber: phoneNumber || null,
          linkPrecedence: 'primary',
        },
      });
      return this.buildResponse([newContact]);
    }

 
    const primaryContacts = matchingContacts.filter(c => c.linkPrecedence === 'primary');

    let primaryContact: Contact;
    
  
    if (primaryContacts.length > 1) {
    
      primaryContacts.sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime());
      primaryContact = primaryContacts[0];
      
     
      for (let i = 1; i < primaryContacts.length; i++) {
        await prisma.contact.update({
          where: { id: primaryContacts[i].id },
          data: {
            linkedId: primaryContact.id,
            linkPrecedence: 'secondary',
            updatedAt: new Date(),
          },
        });
        
       
        await prisma.contact.updateMany({
          where: { linkedId: primaryContacts[i].id },
          data: {
            linkedId: primaryContact.id,
            updatedAt: new Date(),
          },
        });
      }
    } else if (primaryContacts.length === 1) {
      primaryContact = primaryContacts[0];
    } else {
      const linkedId = matchingContacts[0].linkedId!;
      const primary = await prisma.contact.findUnique({
        where: { id: linkedId },
      });
      primaryContact = primary!;
    }

    
    const allLinkedContacts = await this.getAllLinkedContacts(primaryContact.id);
    const shouldCreateNewContact = this.shouldCreateNewSecondaryContact(
      allLinkedContacts,
      email,
      phoneNumber
    );

    if (shouldCreateNewContact) {
      await prisma.contact.create({
        data: {
          email: email || null,
          phoneNumber: phoneNumber || null,
          linkedId: primaryContact.id,
          linkPrecedence: 'secondary',
        },
      });
    }

   
    const finalContacts = await this.getAllLinkedContacts(primaryContact.id);
    return this.buildResponse(finalContacts);
  }

  private async findMatchingContacts(
    email?: string,
    phoneNumber?: string
  ): Promise<Contact[]> {
    const whereConditions: any[] = [];
    
    if (email) {
      whereConditions.push({ email });
    }
    
    if (phoneNumber) {
      whereConditions.push({ phoneNumber });
    }

    if (whereConditions.length === 0) {
      return [];
    }

    const contacts = await prisma.contact.findMany({
      where: {
        OR: whereConditions,
        deletedAt: null,
      },
      orderBy: {
        createdAt: 'asc',
      },
    });
    
    return contacts;
  }

  private async getAllLinkedContacts(primaryId: number): Promise<Contact[]> {
    const contacts = await prisma.contact.findMany({
      where: {
        OR: [
          { id: primaryId },
          { linkedId: primaryId },
        ],
        deletedAt: null,
      },
      orderBy: {
        createdAt: 'asc',
      },
    });
    return contacts;
  }

  private shouldCreateNewSecondaryContact(
    existingContacts: Contact[],
    email?: string,
    phoneNumber?: string
  ): boolean {
   
    if (email && phoneNumber) {
      const exactMatch = existingContacts.find(
        c => c.email === email && c.phoneNumber === phoneNumber
      );
      if (exactMatch) return false;

     
      const hasEmail = existingContacts.some(c => c.email === email);
      const hasPhone = existingContacts.some(c => c.phoneNumber === phoneNumber);
      
     
      return !hasEmail || !hasPhone;
    }

   
    if (email) {
      return !existingContacts.some(c => c.email === email);
    }
    
    if (phoneNumber) {
      return !existingContacts.some(c => c.phoneNumber === phoneNumber);
    }

    return false;
  }

  private buildResponse(contacts: Contact[]): IdentifyResponse {
    // Find primary contact
    const primary = contacts.find(c => c.linkPrecedence === 'primary')!;
    const secondaries = contacts.filter(c => c.linkPrecedence === 'secondary');

    
    const emails: string[] = [];
    const phoneNumbers: string[] = [];

  
    if (primary.email && !emails.includes(primary.email)) {
      emails.push(primary.email);
    }
    if (primary.phoneNumber && !phoneNumbers.includes(primary.phoneNumber)) {
      phoneNumbers.push(primary.phoneNumber);
    }

   
    secondaries.forEach(contact => {
      if (contact.email && !emails.includes(contact.email)) {
        emails.push(contact.email);
      }
      if (contact.phoneNumber && !phoneNumbers.includes(contact.phoneNumber)) {
        phoneNumbers.push(contact.phoneNumber);
      }
    });

    return {
      contact: {
        primaryContatctId: primary.id,
        emails,
        phoneNumbers,
        secondaryContactIds: secondaries.map(c => c.id),
      },
    };
  }
}