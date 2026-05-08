import type { SiteConfig } from '@types'

const config: SiteConfig = {
  site: 'https://asyncadventures.com',
  title: 'Async Adventures',
  description: 'Adventures in the world of software development',
  author: 'John Stewart',
  tags: [
    'Express.js', 'REST API', 'GraphQL', 'MongoDB', 'PostgreSQL', 'Docker',
    'AWS', 'GCP', 'Vercel', 'Firebase', 'Supabase', 'Prisma', 'Next.js',
    'React', 'TypeScript', 'JavaScript', 'HTML', 'CSS', 'SASS', 'SCSS',
    'Code Review', 'Git', 'DevOps', 'CI/CD', 'Unit Testing',
    'Integration Testing', 'Test-Driven Development', 'Agile Development',
    'Microservices', 'Serverless', 'Cloud Computing', 'Database Design',
    'API Development', 'Performance Optimization', 'Code Quality',
    'Clean Code', 'Developer Tools', 'Open Source', 'Tech Stack',
    'Software Engineer Career', 'Programming Tutorial',
    'Coding Best Practices', 'Asynchronous Programming', 'Async/Await',
    'Promises', 'Event Loop', 'Concurrency',
  ],
  socialCardAvatarImage: '',
  font: 'JetBrains Mono Variable',
  pageSize: 10,
  navLinks: [
    { name: 'Posts', url: '/posts' },
    { name: 'Tags', url: '/tags' },
  ],
  socialLinks: {
    github: 'https://github.com/codeinaire',
    email: 'john@asyncadventures.com',
    linkedin: 'https://www.linkedin.com/in/hi-im-john-stewart/',
  },
}

export default config
