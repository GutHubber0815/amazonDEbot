-- Seed data for Early Help app
-- This includes dummy placeholder content

-- Clear existing data (for development)
TRUNCATE categories, entries, glossary_items, support_contacts CASCADE;

-- Insert Categories
INSERT INTO categories (name, description, slug, "order") VALUES
  ('Warning Signs', 'Recognize early indicators of radicalization and extremist influence', 'warning-signs', 1),
  ('Codes & Memes', 'Understanding symbols, language, and online culture', 'codes-memes', 2),
  ('How to Talk', 'Communication strategies for difficult conversations', 'how-to-talk', 3),
  ('Resources', 'Professional help, hotlines, and educational materials', 'resources', 4);

-- Get category IDs for entries
DO $$
DECLARE
  cat_warning_id UUID;
  cat_codes_id UUID;
  cat_talk_id UUID;
  cat_resources_id UUID;
BEGIN
  SELECT id INTO cat_warning_id FROM categories WHERE slug = 'warning-signs';
  SELECT id INTO cat_codes_id FROM categories WHERE slug = 'codes-memes';
  SELECT id INTO cat_talk_id FROM categories WHERE slug = 'how-to-talk';
  SELECT id INTO cat_resources_id FROM categories WHERE slug = 'resources';

  -- Insert Entries (Warning Signs)
  INSERT INTO entries (category_id, title, summary, body, tags, published, "order", last_updated) VALUES
    (cat_warning_id, 'Social Isolation & Withdrawal', 'Understanding sudden changes in social behavior', E'# Social Isolation & Withdrawal\n\nSudden withdrawal from friends and family can be an early warning sign. Watch for:\n\n- Abandonment of longtime friendships\n- Secretive behavior about new relationships\n- Reluctance to discuss daily activities\n- Increased time spent alone or online\n\n## What to do\n\nApproach with curiosity, not accusation. Ask open-ended questions about their day and interests. Maintain trust while staying engaged.\n\n## When to seek help\n\nIf isolation persists for more than 2-3 weeks or is accompanied by other warning signs, consult a professional.', ARRAY['social', 'behavior', 'prevention'], true, 1, NOW()),

    (cat_warning_id, 'Changes in Digital Behavior', 'Recognizing concerning online activity patterns', E'# Changes in Digital Behavior\n\n## Key indicators\n\n- Using encrypted messaging apps exclusively\n- Hiding screens when others approach\n- New online accounts with pseudonyms\n- Participation in closed groups or forums\n- Downloading VPN or anonymity software\n\n## Context matters\n\nPrivacy is normal for adolescents. The concern is when combined with other behavioral changes.\n\n## Approach\n\nDiscuss internet safety openly. Establish clear expectations about online behavior without invading privacy unnecessarily.', ARRAY['digital', 'online', 'behavior'], true, 2, NOW()),

    (cat_warning_id, 'New Interests in Extremist Content', 'Identifying concerning symbols and media consumption', E'# New Interests in Extremist Content\n\nWatch for sudden interest in:\n\n- Extremist political movements\n- Conspiracy theories\n- Historical figures associated with violence\n- Symbols like swastikas, confederate flags, or jihadi imagery\n- Militaristic or survivalist content\n\n## Red flags vs. education\n\nLearning about history is normal. Concern arises when:\n- Content glorifies violence\n- Materials are hidden or lied about\n- Individual expresses agreement with extremist views\n\n## Response\n\nEngage in critical discussions about the content. Ask what they find interesting and why.', ARRAY['content', 'extremism', 'symbols'], true, 3, NOW()),

    (cat_warning_id, 'Us vs. Them Thinking', 'Recognizing binary worldviews and dehumanization', E'# Us vs. Them Thinking\n\n## Warning signs\n\n- Dividing people into absolute categories (good/evil)\n- Dehumanizing language about groups\n- Conspiracy thinking about "them"\n- Loss of nuance in discussions\n- Justifying harm against "enemies"\n\n## Why it matters\n\nThis binary thinking is a core component of radicalization. It makes violence seem justified.\n\n## Intervention\n\n- Challenge generalizations gently\n- Introduce complexity and individual stories\n- Model empathetic language\n- Discuss media literacy and critical thinking', ARRAY['thinking', 'worldview', 'prevention'], true, 4, NOW());

  -- Insert Entries (Codes & Memes)
  INSERT INTO entries (category_id, title, summary, body, tags, published, "order", last_updated) VALUES
    (cat_codes_id, 'Understanding Dog Whistles', 'Coded language and hidden meanings in extremist communication', E'# Understanding Dog Whistles\n\n"Dog whistles" are phrases that seem innocuous but carry hidden meanings to insiders.\n\n## Common examples\n\n- Numeric codes (14, 88, 1488)\n- Seemingly innocent phrases with double meanings\n- References to historical events or figures\n- Memes with layered meanings\n\n## Why they matter\n\nDog whistles allow extremists to communicate publicly while maintaining plausible deniability.\n\n## What parents can do\n\n- Stay informed about current codes\n- Context is crucial—not every use is extremist\n- Ask about meanings directly\n- Consult the glossary in this app', ARRAY['codes', 'language', 'extremism'], true, 1, NOW()),

    (cat_codes_id, 'Meme Culture & Radicalization', 'How internet memes can spread extremist ideologies', E'# Meme Culture & Radicalization\n\n## The role of memes\n\nMemes are powerful tools for:\n- Normalizing extreme views through humor\n- Creating in-group solidarity\n- Desensitizing to violence\n- Spreading propaganda quickly\n\n## Ironic vs. sincere\n\nMany young people claim extremist content is "just jokes." However:\n- Irony can shift to sincerity\n- Communities mixing irony and sincerity are dangerous\n- Repeated exposure normalizes extreme views\n\n## Response strategy\n\nDiscuss the real-world impact of "ironic" hatred. Ask how the targets of jokes might feel.', ARRAY['memes', 'culture', 'online'], true, 2, NOW());

  -- Insert Entries (How to Talk)
  INSERT INTO entries (category_id, title, summary, body, tags, published, "order", last_updated) VALUES
    (cat_talk_id, 'Starting the Conversation', 'Opening dialogue without causing defensiveness', E'# Starting the Conversation\n\n## Principles\n\n1. **Curiosity over accusation**: Ask questions genuinely\n2. **Active listening**: Understand before responding\n3. **Avoid labels**: Don''t call them "radicalized"\n4. **Stay calm**: Emotional reactions shut down dialogue\n\n## Example openers\n\n- "I noticed you''ve been interested in [topic]. What draws you to it?"\n- "Can you help me understand what you mean by...?"\n- "I''m curious about your thoughts on..."\n\n## What to avoid\n\n- Immediate confrontation\n- Dismissing their views as stupid\n- Threatening punishment\n- Giving ultimatums early', ARRAY['communication', 'parenting', 'dialogue'], true, 1, NOW()),

    (cat_talk_id, 'Maintaining Trust During Intervention', 'Balancing safety with relationship preservation', E'# Maintaining Trust During Intervention\n\n## The challenge\n\nYou need to intervene while preserving the relationship that enables intervention.\n\n## Strategies\n\n1. **Be consistent**: Don''t change rules arbitrarily\n2. **Explain reasoning**: Help them understand your concerns\n3. **Respect privacy boundaries**: Don''t snoop unnecessarily\n4. **Acknowledge valid points**: Not everything they say is wrong\n5. **Keep doors open**: Always offer a path back\n\n## When trust is broken\n\nIf you must take action they''ll see as betrayal (like involving authorities):\n- Explain why safety outweighs privacy\n- Maintain contact and support\n- Work with professionals to rebuild', ARRAY['trust', 'parenting', 'intervention'], true, 2, NOW()),

    (cat_talk_id, 'For Teachers: Classroom Discussions', 'Handling extremist views in educational settings', E'# For Teachers: Classroom Discussions\n\n## When students express concerning views\n\n1. **Don''t humiliate**: Never shame in front of peers\n2. **Acknowledge the question**: "That''s a complex topic..."\n3. **Redirect to critical thinking**: "What evidence supports that?"\n4. **Follow up privately**: Continue conversation one-on-one\n\n## Creating safe discussion spaces\n\n- Establish clear ground rules\n- Model respectful disagreement\n- Teach source evaluation\n- Distinguish facts from opinions\n\n## When to escalate\n\n- Threats of violence\n- Harassment of other students\n- Persistent disruption\n- Signs of immediate danger', ARRAY['education', 'teachers', 'classroom'], true, 3, NOW());

  -- Insert Entries (Resources)
  INSERT INTO entries (category_id, title, summary, body, tags, published, "order", last_updated) VALUES
    (cat_resources_id, 'Emergency Contacts & Hotlines', 'Immediate help for crisis situations', E'# Emergency Contacts & Hotlines\n\n## Germany-wide resources\n\n**Police Emergency**: 110\n\n**Violence Prevention Hotline**: 0800 123 4567 (example)\n\n**Youth Counseling**: 116 111 (Nummer gegen Kummer)\n\n## When to call emergency services\n\n- Immediate threat of violence\n- Weapons involvement\n- Credible suicide threats\n- Planning of attacks\n\n## Non-emergency consultation\n\nUse the Help Navigator in this app to find local support organizations.\n\n_Note: Hotline numbers in this demo are placeholders. Use the Help Navigator for real contacts._', ARRAY['emergency', 'hotlines', 'help'], true, 1, NOW()),

    (cat_resources_id, 'Educational Materials on Media Literacy', 'Teaching critical thinking about information sources', E'# Educational Materials on Media Literacy\n\n## Key skills to develop\n\n1. **Source evaluation**: Who created this? Why?\n2. **Bias recognition**: What perspective is being promoted?\n3. **Fact-checking**: Can this be verified?\n4. **Emotional awareness**: How am I being manipulated?\n\n## Recommended activities\n\n- Compare coverage of same event across sources\n- Identify loaded language in articles\n- Trace claims back to original sources\n- Discuss how algorithms create filter bubbles\n\n## Online resources\n\n- Bundeszentrale für politische Bildung\n- Klicksafe.de\n- MediaSmart programs\n\n_See Help Navigator for local workshops and programs._', ARRAY['education', 'media-literacy', 'resources'], true, 2, NOW()),

    (cat_resources_id, 'Understanding the Radicalization Process', 'Educational overview for parents and teachers', E'# Understanding the Radicalization Process\n\n## Typical stages\n\n1. **Pre-radicalization**: Normal life before exposure\n2. **Self-identification**: Beginning to adopt new identity\n3. **Indoctrination**: Deepening commitment to ideology\n4. **Jihadization/Action**: Planning or committing violence\n\n## Important notes\n\n- Not everyone follows this path\n- Process is often non-linear\n- Intervention is possible at any stage\n- Early intervention is most effective\n\n## Risk factors\n\n- Social isolation\n- Identity crisis\n- Grievance (real or perceived)\n- Exposure to extremist content\n- Charismatic recruiter\n\n## Protective factors\n\n- Strong family bonds\n- Positive peer relationships\n- Critical thinking skills\n- Sense of belonging\n- Purpose and meaning in life', ARRAY['education', 'radicalization', 'prevention'], true, 3, NOW());

END $$;

-- Insert Glossary Items
INSERT INTO glossary_items (term, meaning, context, examples, related_terms) VALUES
  ('14 Words', 'A white supremacist slogan: "We must secure the existence of our people and a future for white children"', 'Common in neo-Nazi and white nationalist circles. Often seen as "14" or combined with 88.', 'Usernames like "User1488", tattoos, profile descriptions', ARRAY['88', '1488', 'white supremacy']),

  ('88', 'Numeric code for "Heil Hitler" (H is the 8th letter)', 'Widely used by neo-Nazis as a dog whistle. Can appear in usernames, dates, or prices.', 'Usernames ending in 88, "HH" acronyms', ARRAY['14 Words', '1488', 'dog whistle']),

  ('1488', 'Combination of 14 and 88, signaling white supremacist beliefs', 'The most explicit numeric dog whistle in white supremacist culture.', 'Appears in bios, usernames, or as standalone symbol', ARRAY['14 Words', '88', 'neo-Nazi']),

  ('Based', 'Originally: being yourself without caring about others'' opinions. In extremist contexts: expressing politically incorrect or extremist views', 'Started in hip-hop culture, appropriated by online extremists. Context determines meaning.', '"Based opinion" on controversial statements', ARRAY['red-pilled', 'edgelord']),

  ('Red-pilled', 'Believing you''ve discovered hidden truths rejected by mainstream society', 'From The Matrix. In extremist contexts, refers to accepting conspiracy theories or extremist ideologies.', '"Taking the red pill on [topic]" means accepting an extremist narrative', ARRAY['black-pilled', 'based', 'rabbit hole']),

  ('Black-pilled', 'State of nihilistic despair, believing positive change is impossible', 'More extreme than red-pilled. Associated with incel culture and potential violence.', '"The black pill is realizing nothing matters"', ARRAY['red-pilled', 'incel', 'doomer']),

  ('Pepe the Frog', 'Cartoon frog character appropriated by various online communities', 'Originally innocent meme, co-opted by alt-right and extremists. Context-dependent.', 'Pepe images with Nazi symbols, in extremist contexts', ARRAY['meme', 'alt-right', 'symbol']),

  ('Echo Marks ((()))', 'Triple parentheses used to identify Jewish names or concepts', 'Anti-Semitic dog whistle indicating alleged Jewish involvement or conspiracy.', '(((Name))) or (((mainstream media)))', ARRAY['anti-Semitism', 'dog whistle', 'conspiracy']),

  ('Boogaloo', 'Slang for upcoming civil war or violent anti-government action', 'Used in accelerationist and militia movements. Often with Hawaiian shirt imagery ("Big Luau").', 'References to "boog", "the boogaloo", or "boog bois"', ARRAY['accelerationism', 'civil war', 'militia']),

  ('Accelerationism', 'Belief in hastening societal collapse to enable revolutionary change', 'Extremist ideology promoting actions to destabilize society. Associated with terrorism.', 'Calls to "accelerate" or speed up collapse', ARRAY['boogaloo', 'terrorism', 'extremism']),

  ('Incel', 'Involuntary celibate—men who blame women for their lack of romantic success', 'Online subculture with misogynistic ideology. Associated with several terrorist attacks.', 'Incel forums, "black pill" ideology, references to Elliot Rodger', ARRAY['black-pilled', 'misogyny', 'radicalization']),

  ('Chad/Stacy', 'In incel culture: stereotypical attractive man/woman who rejects incels', 'Dehumanizing archetypes used to justify hatred toward attractive people.', '"Chads and Stacys don''t understand our struggle"', ARRAY['incel', 'black-pilled']),

  ('Cuck/Cuckservative', 'Insult meaning weak, emasculated, or race traitor', 'Used by alt-right to attack conservatives deemed insufficiently extreme.', 'Calling moderate politicians "cucks"', ARRAY['alt-right', 'insult', 'masculinity']),

  ('Great Replacement', 'Conspiracy theory that elites are replacing white populations with immigrants', 'White supremacist conspiracy. Motivated several terrorist attacks.', 'References to "replacement", "white genocide"', ARRAY['conspiracy', 'white supremacy', 'terrorism']),

  ('ZOG', 'Zionist Occupied Government—conspiracy theory about Jewish control', 'Classic anti-Semitic conspiracy theory in neo-Nazi ideology.', '"ZOG controls the media/government"', ARRAY['anti-Semitism', 'conspiracy', 'neo-Nazi']),

  ('Kek/Kekistan', 'Fictional country/religion from online trolling culture, adopted by alt-right', 'Started as joke, became identity marker for alt-right participants.', 'Kekistan flags (resembling Nazi flag), "praise Kek"', ARRAY['alt-right', 'trolling', 'meme']),

  ('Normie', 'Person not aware of or accepting "truth" known to extremists', 'Used to distinguish in-group from mainstream society.', '"Normies don''t understand the truth"', ARRAY['red-pilled', 'in-group', 'othering']),

  ('Clown World/Honk', 'Belief that society is absurd, often tied to accelerationist views', 'Nihilistic meme suggesting modern society deserves destruction.', 'Clown emojis, "honk honk", "we live in a clown world"', ARRAY['accelerationism', 'nihilism', 'meme']),

  ('Groyper', 'Variant of Pepe associated with specific far-right movement', 'Associated with Nick Fuentes and "America First" white nationalist movement.', 'Groyper image memes, "Groyper Army"', ARRAY['white nationalism', 'Pepe', 'far-right']),

  ('Glow/Glowie', 'Slang for federal agent or informant', 'Used to sow paranoia and discredit warnings or moderation.', '"That''s obviously a glowie trying to entrap us"', ARRAY['conspiracy', 'paranoia', 'fed']),

  ('Fed-posting', 'Advocating illegal activity, assumed to be by agents provocateurs', 'Used to signal illegal content while maintaining deniability.', '"Stop fed-posting" (while discussing violence)', ARRAY['glowie', 'violence', 'illegal']),

  ('Day of the Rope', 'Reference to race war from The Turner Diaries', 'Neo-Nazi novel depicting violent white supremacist revolution.', 'References to "DotR" or "rope day"', ARRAY['white supremacy', 'violence', 'terrorism']),

  ('White Sharia', 'Concept of authoritarian patriarchal rule in white nationalist ideology', 'Combines misogyny with white supremacy; advocates controlling women.', 'Discussions of implementing "white sharia"', ARRAY['white supremacy', 'misogyny', 'extremism']),

  ('Fren', 'Friend—used in "frenly" communities mixing innocuous content with extremism', 'Baby-talk disguise for extremist content. "Frenworld" communities often banned.', '"Non-frens" (enemies), "bop the non-frens" (violence)', ARRAY['dog whistle', 'baby-talk', 'disguise']),

  ('Rabbi Hole', 'Anti-Semitic version of "rabbit hole"—conspiracy theories about Jewish control', 'Explicitly anti-Semitic term replacing common phrase.', '"Going down the rabbi hole on [conspiracy]"', ARRAY['anti-Semitism', 'conspiracy', 'radicalization']),

  ('Redacted/In Minecraft', 'Disclaimers added to violent statements for plausible deniability', 'Attempt to avoid moderation while discussing violence.', '"We should [violence] (in Minecraft)"', ARRAY['violence', 'plausible deniability', 'evasion']),

  ('Jogger', 'Racist slur disguised as innocuous word', 'Code word emerging after specific incidents; context makes meaning clear.', 'Used in place of racial slurs in moderated spaces', ARRAY['racism', 'dog whistle', 'slur']),

  ('Power Level', 'How openly someone expresses extremist views', 'From anime/gaming, repurposed to discuss revealing extremism.', '"Don''t reveal your power level to normies"', ARRAY['extremism', 'hiding', 'strategy']),

  ('OK Hand Sign', 'Gesture appropriated as white power symbol in some contexts', 'Started as hoax, then genuinely adopted by some extremists. Context matters.', 'Used deliberately in extremist contexts, often with smirk', ARRAY['symbol', 'white supremacy', 'context-dependent']),

  ('Salil al-Sawarim', 'ISIS anthem, often referenced in jihadist content', 'Recognizing this song can indicate exposure to jihadist propaganda.', 'References to "Clanging of Swords", the song in videos', ARRAY['ISIS', 'jihadism', 'terrorism']);

-- Insert Support Contacts (German cities - DUMMY DATA)
INSERT INTO support_contacts (name, role, region, zip_codes, phone, email, website, description, category) VALUES
  -- Berlin
  ('Berliner Beratungsstelle Radikalisierung', 'all', 'Berlin', ARRAY['10115', '10117', '10119', '10178'], '030-12345678', 'beratung@berlin-demo.de', 'https://example-berlin.de', 'Expert consultation for families and educators concerned about radicalization', 'Prevention'),
  ('Violence Prevention Network Berlin', 'parent', 'Berlin', ARRAY['10115', '10117', '10119'], '030-23456789', 'vpn@berlin-demo.de', 'https://example-vpn-berlin.de', 'Family counseling and intervention programs', 'Intervention'),
  ('Berlin School Counseling', 'teacher', 'Berlin', ARRAY['10115', '10117', '10119', '10178', '10243'], '030-34567890', 'schools@berlin-demo.de', 'https://example-school-berlin.de', 'Resources and training for teachers on extremism prevention', 'Education'),
  ('Youth Welfare Office Berlin Mitte', 'social_worker', 'Berlin', ARRAY['10115', '10117', '10119'], '030-45678901', 'jugend@berlin-demo.de', 'https://example-jugend-berlin.de', 'Social work services for at-risk youth', 'Youth Services'),
  ('Berlin Crisis Intervention', 'all', 'Berlin', ARRAY['10115', '10117', '10119', '10178', '10243', '10247'], '030-56789012', 'crisis@berlin-demo.de', 'https://example-crisis-berlin.de', '24/7 crisis support for immediate concerns', 'Crisis'),

  -- Hamburg
  ('Hamburg Radicalization Prevention', 'all', 'Hamburg', ARRAY['20095', '20144', '20146', '20149'], '040-12345678', 'info@hamburg-demo.de', 'https://example-hamburg.de', 'City-wide prevention program', 'Prevention'),
  ('Eltern-Beratung Hamburg', 'parent', 'Hamburg', ARRAY['20095', '20144', '20146'], '040-23456789', 'eltern@hamburg-demo.de', 'https://example-eltern-hamburg.de', 'Parent support groups and counseling', 'Family Support'),
  ('Hamburg Schools Against Extremism', 'teacher', 'Hamburg', ARRAY['20095', '20144', '20146', '20149', '20251'], '040-34567890', 'schools@hamburg-demo.de', 'https://example-schools-hamburg.de', 'Classroom materials and teacher training', 'Education'),
  ('Hamburg Youth Support', 'social_worker', 'Hamburg', ARRAY['20095', '20144', '20146'], '040-45678901', 'youth@hamburg-demo.de', 'https://example-youth-hamburg.de', 'Case management for at-risk youth', 'Youth Services'),

  -- Munich
  ('Munich Deradicalization Program', 'all', 'Munich', ARRAY['80331', '80335', '80336', '80339'], '089-12345678', 'info@munich-demo.de', 'https://example-munich.de', 'Intervention and exit support', 'Intervention'),
  ('Bayern Family Counseling', 'parent', 'Munich', ARRAY['80331', '80335', '80336'], '089-23456789', 'familie@munich-demo.de', 'https://example-familie-munich.de', 'Family therapy and mediation', 'Family Support'),
  ('Munich Teacher Resource Center', 'teacher', 'Munich', ARRAY['80331', '80335', '80336', '80339', '80469'], '089-34567890', 'teachers@munich-demo.de', 'https://example-teachers-munich.de', 'Workshops and curricular materials', 'Education'),

  -- Cologne
  ('Cologne Prevention Office', 'all', 'Cologne', ARRAY['50667', '50668', '50670', '50672'], '0221-12345678', 'info@cologne-demo.de', 'https://example-cologne.de', 'Coordinated prevention services', 'Prevention'),
  ('Elternhilfe Köln', 'parent', 'Cologne', ARRAY['50667', '50668', '50670'], '0221-23456789', 'hilfe@cologne-demo.de', 'https://example-hilfe-cologne.de', 'Support groups and workshops for parents', 'Family Support'),
  ('NRW School Consultation', 'teacher', 'Cologne', ARRAY['50667', '50668', '50670', '50672', '50674'], '0221-34567890', 'schools@cologne-demo.de', 'https://example-schools-cologne.de', 'Regional school support program', 'Education'),

  -- Frankfurt
  ('Frankfurt Exit Program', 'all', 'Frankfurt', ARRAY['60311', '60313', '60314', '60316'], '069-12345678', 'exit@frankfurt-demo.de', 'https://example-frankfurt.de', 'Support for leaving extremist groups', 'Exit Support'),
  ('Frankfurt Family Center', 'parent', 'Frankfurt', ARRAY['60311', '60313', '60314'], '069-23456789', 'family@frankfurt-demo.de', 'https://example-family-frankfurt.de', 'Family counseling and education', 'Family Support'),

  -- Stuttgart
  ('Stuttgart Prevention Network', 'all', 'Stuttgart', ARRAY['70173', '70174', '70176', '70178'], '0711-12345678', 'network@stuttgart-demo.de', 'https://example-stuttgart.de', 'Multi-agency prevention coordination', 'Prevention'),
  ('Baden-Württemberg Parent Support', 'parent', 'Stuttgart', ARRAY['70173', '70174', '70176'], '0711-23456789', 'parents@stuttgart-demo.de', 'https://example-parents-stuttgart.de', 'Regional parent consultation service', 'Family Support'),

  -- Düsseldorf
  ('Düsseldorf Youth Counseling', 'all', 'Düsseldorf', ARRAY['40210', '40211', '40212', '40213'], '0211-12345678', 'youth@duesseldorf-demo.de', 'https://example-duesseldorf.de', 'Youth-focused counseling and mentoring', 'Youth Services'),
  ('Düsseldorf School Office', 'teacher', 'Düsseldorf', ARRAY['40210', '40211', '40212', '40213', '40215'], '0211-23456789', 'schools@duesseldorf-demo.de', 'https://example-schools-duesseldorf.de', 'Teacher training and support', 'Education'),

  -- Leipzig
  ('Leipzig Tolerance Center', 'all', 'Leipzig', ARRAY['04103', '04105', '04107', '04109'], '0341-12345678', 'toleranz@leipzig-demo.de', 'https://example-leipzig.de', 'Democracy education and prevention', 'Prevention'),
  ('Sachsen Family Network', 'parent', 'Leipzig', ARRAY['04103', '04105', '04107'], '0341-23456789', 'familie@leipzig-demo.de', 'https://example-familie-leipzig.de', 'Family support and workshops', 'Family Support'),

  -- Dortmund
  ('Dortmund Against Extremism', 'all', 'Dortmund', ARRAY['44135', '44137', '44139', '44141'], '0231-12345678', 'info@dortmund-demo.de', 'https://example-dortmund.de', 'Community-based prevention', 'Prevention'),
  ('Dortmund Youth Office', 'social_worker', 'Dortmund', ARRAY['44135', '44137', '44139'], '0231-23456789', 'jugend@dortmund-demo.de', 'https://example-jugend-dortmund.de', 'Social services for youth', 'Youth Services'),

  -- Essen
  ('Essen Diversity Office', 'all', 'Essen', ARRAY['45127', '45128', '45130', '45131'], '0201-12345678', 'diversity@essen-demo.de', 'https://example-essen.de', 'Intercultural prevention programs', 'Prevention'),
  ('Essen Parent Forum', 'parent', 'Essen', ARRAY['45127', '45128', '45130'], '0201-23456789', 'forum@essen-demo.de', 'https://example-forum-essen.de', 'Monthly parent meetings and resources', 'Family Support'),

  -- Bremen
  ('Bremen Prevention Bureau', 'all', 'Bremen', ARRAY['28195', '28199', '28201', '28203'], '0421-12345678', 'bureau@bremen-demo.de', 'https://example-bremen.de', 'Citywide prevention coordination', 'Prevention'),
  ('Bremen Family Help', 'parent', 'Bremen', ARRAY['28195', '28199', '28201'], '0421-23456789', 'hilfe@bremen-demo.de', 'https://example-hilfe-bremen.de', 'Family counseling and intervention', 'Family Support'),

  -- Dresden
  ('Dresden Democracy Center', 'all', 'Dresden', ARRAY['01067', '01069', '01097', '01099'], '0351-12345678', 'democracy@dresden-demo.de', 'https://example-dresden.de', 'Democratic education and prevention', 'Prevention'),
  ('Sachsen Teacher Academy', 'teacher', 'Dresden', ARRAY['01067', '01069', '01097', '01099', '01108'], '0351-23456789', 'academy@dresden-demo.de', 'https://example-academy-dresden.de', 'Professional development for educators', 'Education'),

  -- Hannover
  ('Hannover Tolerance Project', 'all', 'Hannover', ARRAY['30159', '30161', '30163', '30165'], '0511-12345678', 'projekt@hannover-demo.de', 'https://example-hannover.de', 'Prevention through education', 'Prevention'),
  ('Niedersachsen Family Support', 'parent', 'Hannover', ARRAY['30159', '30161', '30163'], '0511-23456789', 'familie@hannover-demo.de', 'https://example-familie-hannover.de', 'Regional family counseling', 'Family Support'),

  -- Nuremberg
  ('Nuremberg Youth Prevention', 'all', 'Nuremberg', ARRAY['90402', '90403', '90408', '90409'], '0911-12345678', 'jugend@nuremberg-demo.de', 'https://example-nuremberg.de', 'Youth-focused prevention services', 'Youth Services'),
  ('Bayern School Network', 'teacher', 'Nuremberg', ARRAY['90402', '90403', '90408', '90409', '90411'], '0911-23456789', 'schools@nuremberg-demo.de', 'https://example-schools-nuremberg.de', 'Network of schools against extremism', 'Education'),

  -- Duisburg
  ('Duisburg Integration Office', 'all', 'Duisburg', ARRAY['47051', '47053', '47055', '47057'], '0203-12345678', 'integration@duisburg-demo.de', 'https://example-duisburg.de', 'Integration and prevention services', 'Prevention'),
  ('Ruhrgebiet Parent Network', 'parent', 'Duisburg', ARRAY['47051', '47053', '47055'], '0203-23456789', 'eltern@duisburg-demo.de', 'https://example-eltern-duisburg.de', 'Regional parent support network', 'Family Support'),

  -- Bochum
  ('Bochum Civic Education', 'all', 'Bochum', ARRAY['44787', '44789', '44791', '44793'], '0234-12345678', 'civic@bochum-demo.de', 'https://example-bochum.de', 'Civic education and prevention', 'Prevention'),
  ('Bochum Teacher Support', 'teacher', 'Bochum', ARRAY['44787', '44789', '44791'], '0234-23456789', 'teachers@bochum-demo.de', 'https://example-teachers-bochum.de', 'Consultation for educators', 'Education'),

  -- Wuppertal
  ('Wuppertal Youth Services', 'all', 'Wuppertal', ARRAY['42103', '42105', '42107', '42109'], '0202-12345678', 'jugend@wuppertal-demo.de', 'https://example-wuppertal.de', 'Comprehensive youth services', 'Youth Services'),
  ('Wuppertal Family Counseling', 'parent', 'Wuppertal', ARRAY['42103', '42105', '42107'], '0202-23456789', 'beratung@wuppertal-demo.de', 'https://example-beratung-wuppertal.de', 'Professional family counseling', 'Family Support'),

  -- Bielefeld
  ('Bielefeld Prevention Office', 'all', 'Bielefeld', ARRAY['33602', '33604', '33605', '33607'], '0521-12345678', 'prevention@bielefeld-demo.de', 'https://example-bielefeld.de', 'Municipal prevention services', 'Prevention'),
  ('NRW Youth Network Bielefeld', 'social_worker', 'Bielefeld', ARRAY['33602', '33604', '33605'], '0521-23456789', 'network@bielefeld-demo.de', 'https://example-network-bielefeld.de', 'Youth worker support network', 'Youth Services'),

  -- Bonn
  ('Bonn Democracy Initiative', 'all', 'Bonn', ARRAY['53111', '53113', '53115', '53117'], '0228-12345678', 'demokratie@bonn-demo.de', 'https://example-bonn.de', 'Democratic values education', 'Prevention'),
  ('Bonn Parent Academy', 'parent', 'Bonn', ARRAY['53111', '53113', '53115'], '0228-23456789', 'akademie@bonn-demo.de', 'https://example-akademie-bonn.de', 'Educational workshops for parents', 'Family Support'),

  -- Münster
  ('Münster Tolerance Office', 'all', 'Münster', ARRAY['48143', '48145', '48147', '48149'], '0251-12345678', 'toleranz@muenster-demo.de', 'https://example-muenster.de', 'Promoting tolerance and prevention', 'Prevention'),
  ('Westfalen School Consultation', 'teacher', 'Münster', ARRAY['48143', '48145', '48147', '48149', '48151'], '0251-23456789', 'schools@muenster-demo.de', 'https://example-schools-muenster.de', 'Regional school support', 'Education'),

  -- Karlsruhe
  ('Karlsruhe Youth Protection', 'all', 'Karlsruhe', ARRAY['76131', '76133', '76135', '76137'], '0721-12345678', 'jugend@karlsruhe-demo.de', 'https://example-karlsruhe.de', 'Youth protection and prevention', 'Youth Services'),
  ('Baden Parent Support', 'parent', 'Karlsruhe', ARRAY['76131', '76133', '76135'], '0721-23456789', 'eltern@karlsruhe-demo.de', 'https://example-eltern-karlsruhe.de', 'Regional parent consultation', 'Family Support'),

  -- Mannheim
  ('Mannheim Against Hate', 'all', 'Mannheim', ARRAY['68159', '68161', '68163', '68165'], '0621-12345678', 'hate@mannheim-demo.de', 'https://example-mannheim.de', 'Anti-hate and prevention programs', 'Prevention'),
  ('Mannheim Family Center', 'parent', 'Mannheim', ARRAY['68159', '68161', '68163'], '0621-23456789', 'family@mannheim-demo.de', 'https://example-family-mannheim.de', 'Family support services', 'Family Support');
