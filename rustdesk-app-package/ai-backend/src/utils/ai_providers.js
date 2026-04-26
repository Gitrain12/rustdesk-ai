const logger = require('./logger');

const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
const DEEPSEEK_BASE_URL = process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com';

const QIANWEN_API_KEY = process.env.QIANWEN_API_KEY;
const QIANWEN_BASE_URL = process.env.QIANWEN_BASE_URL || 'https://dashscope.aliyuncs.com/api/v1';

async function callDeepSeekAPI(messages, model = 'deepseek-chat', maxTokens = 1000) {
  if (!DEEPSEEK_API_KEY) {
    throw new Error('DeepSeek API key not configured');
  }

  const response = await fetch(`${DEEPSEEK_BASE_URL}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
    },
    body: JSON.stringify({
      model: model,
      messages: messages,
      max_tokens: maxTokens,
      temperature: 0.7,
    }),
  });

  if (!response.ok) {
    const errorData = await response.text();
    throw new Error(`DeepSeek API error: ${response.status} - ${errorData}`);
  }

  return await response.json();
}

async function callQianwenAPI(messages, model = 'qwen-vl-plus') {
  if (!QIANWEN_API_KEY) {
    throw new Error('Qianwen API key not configured');
  }

  const response = await fetch(`${QIANWEN_BASE_URL}/services/aigc/multimodal-generation/generation`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${QIANWEN_API_KEY}`,
    },
    body: JSON.stringify({
      model: model,
      input: {
        messages: messages,
      },
      parameters: {
        max_tokens: 1500,
      },
    }),
  });

  if (!response.ok) {
    const errorData = await response.text();
    throw new Error(`Qianwen API error: ${response.status} - ${errorData}`);
  }

  return await response.json();
}

async function callQianwenChat(messages, model = 'qwen-turbo') {
  if (!QIANWEN_API_KEY) {
    throw new Error('Qianwen API key not configured');
  }

  const response = await fetch(`${QIANWEN_BASE_URL}/services/aigc/text-generation/generation`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${QIANWEN_API_KEY}`,
    },
    body: JSON.stringify({
      model: model,
      input: {
        messages: messages,
      },
      parameters: {
        max_tokens: 1500,
      },
    }),
  });

  if (!response.ok) {
    const errorData = await response.text();
    throw new Error(`Qianwen API error: ${response.status} - ${errorData}`);
  }

  return await response.json();
}

module.exports = {
  callDeepSeekAPI,
  callQianwenAPI,
  callQianwenChat,
  DEEPSEEK_API_KEY,
  QIANWEN_API_KEY,
};