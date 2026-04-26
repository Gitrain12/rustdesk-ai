const express = require('express');
const router = express.Router();
const { callDeepSeekAPI } = require('../utils/ai_providers');
const logger = require('../utils/logger');

const SUPPORTED_LANGUAGES = {
  en: 'English',
  zh: 'Chinese',
  es: 'Spanish',
  fr: 'French',
  de: 'German',
  ja: 'Japanese',
  ko: 'Korean',
  ru: 'Russian',
  ar: 'Arabic',
  pt: 'Portuguese',
};

router.post('/', async (req, res, next) => {
  try {
    const { text, target } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'Text is required' });
    }

    if (!target || !SUPPORTED_LANGUAGES[target]) {
      return res.status(400).json({
        error: 'Invalid target language',
        supportedLanguages: SUPPORTED_LANGUAGES,
      });
    }

    logger.info('Translate request received (DeepSeek)', { target, textLength: text.length });

    const messages = [
      {
        role: 'system',
        content: `You are a professional translator. Translate the following text to ${SUPPORTED_LANGUAGES[target]}. Only provide the translation, nothing else.`,
      },
      {
        role: 'user',
        content: text,
      },
    ];

    const completion = await callDeepSeekAPI(messages, 'deepseek-chat', 2000);

    const translatedText = completion.choices[0].message.content;

    logger.info('Translate request completed (DeepSeek)');

    res.json({
      success: true,
      result: {
        original: text,
        translated: translatedText,
        sourceLang: 'auto',
        targetLang: target,
        targetLangName: SUPPORTED_LANGUAGES[target],
      },
    });
  } catch (error) {
    logger.error('Translate error:', error);
    next(error);
  }
});

router.get('/languages', (req, res) => {
  res.json({
    success: true,
    languages: SUPPORTED_LANGUAGES,
  });
});

module.exports = router;