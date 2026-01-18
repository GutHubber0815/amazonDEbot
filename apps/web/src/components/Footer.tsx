export function Footer() {
  return (
    <footer className="bg-gray-100 dark:bg-slate-900 border-t border-gray-200 dark:border-slate-700 mt-16">
      <div className="container mx-auto px-4 py-8">
        <div className="grid md:grid-cols-3 gap-8">
          <div>
            <h3 className="font-semibold mb-3 text-gray-900 dark:text-white">About Early Help</h3>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Non-partisan educational platform for radicalization prevention and civic education.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-3 text-gray-900 dark:text-white">Quick Links</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <a href="/library" className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400">
                  Content Library
                </a>
              </li>
              <li>
                <a href="/glossary" className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400">
                  Glossary
                </a>
              </li>
              <li>
                <a href="/help-navigator" className="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400">
                  Help Navigator
                </a>
              </li>
            </ul>
          </div>
          <div>
            <h3 className="font-semibold mb-3 text-gray-900 dark:text-white">Privacy & Safety</h3>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">
              This app stores minimal data and respects your privacy.
            </p>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              <strong>Emergency:</strong> Call 110 (Police) or 116 111 (Youth Helpline)
            </p>
          </div>
        </div>
        <div className="mt-8 pt-8 border-t border-gray-200 dark:border-slate-700 text-center text-sm text-gray-600 dark:text-gray-400">
          <p>&copy; {new Date().getFullYear()} Early Help. Educational content for prevention purposes.</p>
        </div>
      </div>
    </footer>
  );
}
