import { Request, Response } from 'express';
import { CustomCategory } from '../../models';

interface Category {
  name: string;
  imageUrl: string;
  narration?: string;
}

interface UserCategoryDocument {
  userId: string;
  categories: Category[];
  save: () => Promise<any>;
}

export const addCustomCategory = async (req: Request, res: Response): Promise<any> => {
  const userId = req.user!._id;
  const { name, imageUrl, narration } = req.body;

  if (!name || !imageUrl) {
    return res.status(400).json({ message: 'Name and imageUrl are required.' });
  }

  const safeNarration = narration ?? '';

  try {
    let userCategory = (await CustomCategory.findOne({ userId })) as UserCategoryDocument | null;

    if (!userCategory) {
      // Create new document if user doesn't exist
      userCategory = new CustomCategory({
        userId,
        categories: [{ name, imageUrl, narration: safeNarration }],
      });
    } else {
      // Find index of category with the same name
      const existingIndex = userCategory.categories.findIndex((cat) => cat.name === name);

      if (existingIndex !== -1) {
        // Update existing category
        userCategory.categories[existingIndex].imageUrl = imageUrl;
        userCategory.categories[existingIndex].narration = safeNarration;
      } else {
        // Add new category
        userCategory.categories.push({
          name,
          imageUrl,
          narration: safeNarration,
        });
      }
    }

    await userCategory!.save();
    res.status(200).json({
      message: 'Category saved successfully',
      data: userCategory,
    });
  } catch (err: any) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

export const getCustomCategories = async (req: Request, res: Response): Promise<any> => {
  try {
    const userId = req.user!._id;
    const categories = await CustomCategory.findOne({ userId });

    res.status(200).json(categories || { userId, categories: [] });
  } catch (err) {
    console.error('Fetch Category Error:', err);
    res.status(500).json({ error: 'Failed to fetch custom categories' });
  }
};
