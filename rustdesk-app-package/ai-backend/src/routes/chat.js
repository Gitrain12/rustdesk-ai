const express = require('express');
const router = express.Router();
const { callDeepSeekAPI, callQianwenAPI } = require('../utils/ai_providers');
const logger = require('../utils/logger');

const SYSTEM_PROMPT = `You are an AI assistant helping with remote desktop control. Analyze the screen content and provide helpful answers.`;

router.post('/', async (req, res, next) => {
  try {
    const { message, context } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    logger.info('Chat request received (DeepSeek)', { messageLength: message.length });

    const messages = [
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: message },
    ];

    const completion = await callDeepSeekAPI(messages, 'deepseek-chat');

    const responseText = completion.choices[0].message.content;

    logger.info('Chat request completed (DeepSeek)', {
      responseLength: responseText.length,
      tokens: completion.usage?.total_tokens,
    });

    res.json({
      success: true,
      result: {
        response: responseText,
        model: 'deepseek-chat',
      },
    });
  } catch (error) {
    logger.error('Chat error:', error);
    next(error);
  }
});

router.post('/with-context', async (req, res, next) => {
  try {
    const { message, imageBase64, context } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    logger.info('Chat with context request received (Qianwen Vision)', {
      hasImage: !!imageBase64,
      messageLength: message.length,
    });

    const messages = [
      {
        role: 'user',
        content: [
          {
            image: `data:image/jpeg;base64,${imageBase64}`,
          },
          {
            text: message,
          },
        ],
      },
    ];

    const completion = await callQianwenAPI(messages, 'qwen-vl-plus');

    const responseText = completion.output?.choices?.[0]?.message?.content || '';

    logger.info('Chat with context request completed (Qianwen Vision)');

    res.json({
      success: true,
      result: {
        response: responseText,
        model: 'qwen-vl-plus',
      },
    });
  } catch (error) {
    logger.error('Chat with context error:', error);
    next(error);
  }
});

module.exports = router;