import type { ChecklistItem, ChecklistProgress, ChecklistResult } from '@early-help/types';

/**
 * Default checklist items
 */
export const DEFAULT_CHECKLIST_ITEMS: ChecklistItem[] = [
  {
    id: 'c1',
    text: 'Sudden change in friend groups or social isolation',
    explanation: 'Withdrawal from longtime friends or sudden new peer groups can indicate identity shifts or external influence.',
    category: 'social',
  },
  {
    id: 'c2',
    text: 'Increased secrecy about online activities',
    explanation: 'Hiding screens, using encrypted apps excessively, or refusing to discuss online interactions may signal concerning content consumption.',
    category: 'digital',
  },
  {
    id: 'c3',
    text: 'New interest in extremist symbols, memes, or language',
    explanation: 'Unfamiliar logos, coded language, or memes associated with extremist groups should be taken seriously.',
    category: 'content',
  },
  {
    id: 'c4',
    text: 'Us vs. them mentality or conspiracy thinking',
    explanation: 'Increasingly rigid worldviews that divide people into absolute categories can be early warning signs.',
    category: 'thinking',
  },
  {
    id: 'c5',
    text: 'Rejection of previously held values or beliefs',
    explanation: 'Sudden dismissal of family values, educational institutions, or democratic principles.',
    category: 'values',
  },
  {
    id: 'c6',
    text: 'Justification of violence or hatred toward groups',
    explanation: 'Any rhetoric that dehumanizes or advocates harm against identifiable groups is a red flag.',
    category: 'thinking',
  },
  {
    id: 'c7',
    text: 'Consuming media from questionable sources exclusively',
    explanation: 'Relying solely on fringe websites, channels, or forums while dismissing mainstream or verified sources.',
    category: 'content',
  },
  {
    id: 'c8',
    text: 'Changes in mood: increased anger or hopelessness',
    explanation: 'Persistent negative emotions can make individuals vulnerable to extremist narratives offering simple answers.',
    category: 'emotional',
  },
];

/**
 * Calculate checklist results based on progress
 */
export function calculateChecklistResult(progress: ChecklistProgress): ChecklistResult {
  const checkedIds = Object.keys(progress).filter((id) => progress[id]);
  const checkedCount = checkedIds.length;
  const totalCount = DEFAULT_CHECKLIST_ITEMS.length;

  // Count by category
  const categories: { [category: string]: number } = {};
  checkedIds.forEach((id) => {
    const item = DEFAULT_CHECKLIST_ITEMS.find((i) => i.id === id);
    if (item) {
      categories[item.category] = (categories[item.category] || 0) + 1;
    }
  });

  // Generate interpretation
  let interpretation = '';
  let nextSteps: string[] = [];

  if (checkedCount === 0) {
    interpretation = 'No warning signs checked. Continue to maintain open communication and stay engaged.';
    nextSteps = [
      'Keep communication channels open',
      'Stay informed about digital literacy',
      'Encourage critical thinking skills',
    ];
  } else if (checkedCount <= 2) {
    interpretation = 'Few warning signs noted. This may be normal adolescent development, but stay attentive.';
    nextSteps = [
      'Have open, non-judgmental conversations',
      'Show interest in their online activities',
      'Reinforce media literacy skills',
      'Monitor for changes',
    ];
  } else if (checkedCount <= 4) {
    interpretation = 'Several warning signs present. Consider taking action to understand what\'s happening.';
    nextSteps = [
      'Initiate calm, curious conversations',
      'Consult with school counselors or teachers',
      'Review online activity together',
      'Consider professional guidance from the Help Navigator',
      'Document patterns you notice',
    ];
  } else {
    interpretation = 'Multiple warning signs checked. It\'s important to seek professional support.';
    nextSteps = [
      'Reach out to professional support services immediately',
      'Use the Help Navigator to find local resources',
      'Consult with school administration and counselors',
      'Consider involving mental health professionals',
      'Document specific behaviors and statements',
      'Do not confront aggressively—maintain trust',
    ];
  }

  return {
    checkedCount,
    totalCount,
    categories,
    interpretation,
    nextSteps,
  };
}

/**
 * Get items by category
 */
export function getItemsByCategory(category: string): ChecklistItem[] {
  return DEFAULT_CHECKLIST_ITEMS.filter((item) => item.category === category);
}

/**
 * Get all categories
 */
export function getCategories(): string[] {
  const categories = new Set(DEFAULT_CHECKLIST_ITEMS.map((item) => item.category));
  return Array.from(categories).sort();
}
