import { Router, Request, Response } from 'express';
import { ContactService } from '../services/contactService';
import { IdentifyRequest } from '../types';

const router = Router();
const contactService = new ContactService();

router.post('/identify', async (req: Request, res: Response) => {
  try {
    const request: IdentifyRequest = req.body;

    // Validate request
    if (!request.email && !request.phoneNumber) {
      return res.status(400).json({
        error: 'Either email or phoneNumber must be provided',
      });
    }

    const response = await contactService.identify(request);
    return res.status(200).json(response);
    
  } catch (error) {
    console.error('Error in /identify:', error);
    return res.status(500).json({
      error: 'Internal server error',
    });
  }
});

export default router;