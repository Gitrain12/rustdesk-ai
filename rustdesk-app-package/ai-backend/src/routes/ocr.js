const express = require('express');
const router = express.Router();
const multer = require('multer');
const { callQianwenAPI } = require('../utils/ai_providers');
const logger = require('../utils/logger');

const upload = multer({
  limit: { fileSize: 5 * 1024 * 1024 },
  storage: multer.memoryStorage(),
});

router.post('/', upload.single('image'), async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image provided' });
    }

    logger.info('OCR request received (using Qianwen Vision)', { size: req.file.size });

    const imageBase64 = req.file.buffer.toString('base64');

    const messages = [
      {
        role: 'user',
        content: [
          {
            image: `data:image/jpeg;base64,${imageBase64}`,
          },
          {
            text: 'Please extract all text from this image. Return only the extracted text, nothing else.',
          },
        ],
      },
    ];

    const completion = await callQianwenAPI(messages, 'qwen-vl-plus');

    const extractedText = completion.output?.choices?.[0]?.message?.content || '';

    logger.info('OCR request completed', { textLength: extractedText.length });

    res.json({
      success: true,
      result: {
        text: extractedText,
        language: 'detected',
      },
    });
  } catch (error) {
    logger.error('OCR error:', error);
    next(error);
  }
});

router.post('/batch', upload.array('images', 10), async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: 'No images provided' });
    }

    logger.info('Batch OCR request received', { count: req.files.length });

    const results = await Promise.all(
      req.files.map(async (file) => {
        const imageBase64 = file.buffer.toString('base64');

        const messages = [
          {
            role: 'user',
            content: [
              {
                image: `data:image/jpeg;base64,${imageBase64}`,
              },
              {
                text: 'Please extract all text from this image. Return only the extracted text.',
              },
            ],
          },
        ];

        const completion = await callQianwenAPI(messages, 'qwen-vl-plus');
        const text = completion.output?.choices?.[0]?.message?.content || '';

        return {
          filename: file.originalname,
          text: text,
        };
      })
    );

    res.json({
      success: true,
      results,
    });
  } catch (error) {
    logger.error('Batch OCR error:', error);
    next(error);
  }
});

module.exports = router;