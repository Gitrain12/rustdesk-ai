const express = require('express');
const router = express.Router();
const { callQianwenAPI } = require('../utils/ai_providers');
const logger = require('../utils/logger');

const CODE_REVIEW_PROMPT = `You are an expert code reviewer. Analyze the code in the provided image and provide:
1. Code functionality summary
2. Potential bugs or issues
3. Security concerns
4. Code quality suggestions
5. Best practices recommendations`;

router.post('/', async (req, res, next) => {
  try {
    const { imageBase64, language } = req.body;

    if (!imageBase64) {
      return res.status(400).json({ error: 'Code image is required' });
    }

    logger.info('Code review request received (Qianwen Vision)');

    const messages = [
      {
        role: 'user',
        content: [
          {
            image: `data:image/jpeg;base64,${imageBase64}`,
          },
          {
            text: CODE_REVIEW_PROMPT + (language ? `\n\nProgramming language if detectable: ${language}` : ''),
          },
        ],
      },
    ];

    const completion = await callQianwenAPI(messages, 'qwen-vl-plus');

    const responseText = completion.output?.choices?.[0]?.message?.content || '';

    logger.info('Code review request completed (Qianwen Vision)');

    res.json({
      success: true,
      result: {
        review: responseText,
        model: 'qwen-vl-plus',
      },
    });
  } catch (error) {
    logger.error('Code review error:', error);
    next(error);
  }
});

module.exports = router;