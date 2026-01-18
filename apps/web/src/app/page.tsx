import Link from 'next/link';

export default function HomePage() {
  return (
    <div className="bg-gradient-to-b from-primary-50 to-white dark:from-slate-900 dark:to-slate-800">
      {/* Hero Section */}
      <section className="container mx-auto px-4 py-16 md:py-24">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-6xl font-bold mb-6 text-gray-900 dark:text-white">
            Early Help
          </h1>
          <p className="text-xl md:text-2xl mb-8 text-gray-700 dark:text-gray-300">
            Prevention & Civic Education for Parents and Teachers
          </p>
          <p className="text-lg mb-12 text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
            Educational resources on media literacy, radicalization prevention, and support navigation.
            Non-partisan, evidence-based, GDPR-first.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/library" className="btn-primary">
              Explore Content Library
            </Link>
            <Link href="/checklist" className="btn-secondary">
              Warning Signs Checklist
            </Link>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="container mx-auto px-4 py-16">
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 max-w-6xl mx-auto">
          <Link href="/library" className="card hover:shadow-lg transition-shadow">
            <div className="text-4xl mb-4">📚</div>
            <h3 className="text-xl font-semibold mb-2">Content Library</h3>
            <p className="text-gray-600 dark:text-gray-400">
              Educational articles on warning signs, communication strategies, and resources
            </p>
          </Link>

          <Link href="/glossary" className="card hover:shadow-lg transition-shadow">
            <div className="text-4xl mb-4">🔍</div>
            <h3 className="text-xl font-semibold mb-2">Codes & Memes</h3>
            <p className="text-gray-600 dark:text-gray-400">
              Searchable lexicon of symbols, language, and online extremist culture
            </p>
          </Link>

          <Link href="/checklist" className="card hover:shadow-lg transition-shadow">
            <div className="text-4xl mb-4">✓</div>
            <h3 className="text-xl font-semibold mb-2">Signs Checklist</h3>
            <p className="text-gray-600 dark:text-gray-400">
              Self-guided assessment with educational context and next steps
            </p>
          </Link>

          <Link href="/help-navigator" className="card hover:shadow-lg transition-shadow">
            <div className="text-4xl mb-4">🧭</div>
            <h3 className="text-xl font-semibold mb-2">Help Navigator</h3>
            <p className="text-gray-600 dark:text-gray-400">
              Find local support contacts based on your role and region
            </p>
          </Link>
        </div>
      </section>

      {/* Privacy Notice */}
      <section className="container mx-auto px-4 py-12">
        <div className="max-w-3xl mx-auto card bg-primary-50 dark:bg-slate-700">
          <h3 className="text-xl font-semibold mb-4">🔒 Privacy by Design</h3>
          <ul className="space-y-2 text-gray-700 dark:text-gray-300">
            <li>✓ No personal data about minors stored</li>
            <li>✓ Checklist progress saved locally on your device</li>
            <li>✓ Optional login for favorites sync only</li>
            <li>✓ No user-generated content or forums</li>
            <li>✓ GDPR-compliant data handling</li>
          </ul>
        </div>
      </section>

      {/* About */}
      <section className="container mx-auto px-4 py-16">
        <div className="max-w-3xl mx-auto text-center">
          <h2 className="text-3xl font-bold mb-6">About Early Help</h2>
          <p className="text-lg text-gray-700 dark:text-gray-300 mb-4">
            Early Help is a non-partisan educational platform designed to support parents,
            teachers, and social workers in recognizing and responding to early signs of radicalization.
          </p>
          <p className="text-lg text-gray-700 dark:text-gray-300">
            We provide evidence-based information, communication strategies, and connections
            to professional support—all while respecting privacy and maintaining neutrality.
          </p>
        </div>
      </section>
    </div>
  );
}
