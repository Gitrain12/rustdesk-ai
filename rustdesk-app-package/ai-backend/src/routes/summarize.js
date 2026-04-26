const express = require('express');
const router = express.Router();
const { callQianwenAPI } = require('../utils/ai_providers');
const logger = require('../utils/logger');

const SUMMARIZE_PROMPT = `You are an AI assistant. Analyze the screen content in the image and provide a concise summary covering:
1. Main content/purpose of the screen
2. Key UI elements visible
3. Any important information displayed
4. Context of what application this appears to be`;

router.post('/', async (req, res, next) => {
  try {
    const { imageBase64 } = req.body;

    if (!imageBase64) {
      return res.status(400).json({ error: 'Screen image is required' });
    }

    logger.info('Summarize request received (Qianwen Vision)');

    const messages = [
      {
        role: 'user',
        content: [
          {
            image: `data:image/jpeg;base64,${imageBase64}`,
          },
          {
            text: SUMMARIZE_PROMPT,
          },
        ],
      },
    ];

    const completion = await callQianwenAPI(messages, 'qwen-vl-plus');

    const responseText = completion.output?.choices?.[0]?.message?.content || '';

    logger.info('Summarize request completed (Qianwen Vision)');

    res.json({
      success: true,
      result: {
        summary: responseText,
        model: 'qwen-vl-plus',
      },
    });
  } catch (error) {
    logger.error('Summarize error:', error);
    next(error);
  }
});

module.exports = router;