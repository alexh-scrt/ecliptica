import React, { useState } from 'react';
import { ChevronLeft, ChevronRight, Shield, Zap, Lock, Smartphone, TrendingUp, Users, Award, Target, Clock, DollarSign }
from 'lucide-react';

const PitchDeck = () => {
const [currentSlide, setCurrentSlide] = useState(0);

const slides = [
{
title: "Ecliptica",
subtitle: "Privacy at the Speed of Light",
type: "cover",
content: "The World's First Post-Quantum Privacy Blockchain with Practical Performance"
},
{
title: "The $320B Problem",
type: "problem",
content: [
{ icon: Lock, text: "Current privacy chains (Zcash, Monero) vulnerable to quantum computers", stat: "Harvest now,
decrypt later" },
{ icon: Zap, text: "Privacy comes at massive performance cost", stat: "<1,000 TPS" }, { icon: DollarSign,
    text: "MEV exploitation costs users billions annually" , stat: "$2B+ extracted in 2024" }, { icon: Smartphone,
    text: "Privacy requires running full nodes - impossible on mobile" , stat: "99% can't validate" } ] }, {
    title: "The Ecliptica Solution" , type: "solution" , content: [ { title: "Post-Quantum Security" ,
    desc: "100% quantum-resistant crypto stack (ML-KEM, ML-DSA, zk-STARKs)" , icon: Shield }, {
    title: "Practical Performance" , desc: "50,000 TPS target with sub-second finality" , icon: Zap }, {
    title: "Mobile-First Privacy" , desc: "Light clients that verify on phones via recursive proofs" , icon: Smartphone
    }, { title: "95% MEV Reduction" , desc: "Threshold encryption + cryptographic guarantees" , icon: Lock } ] }, {
    title: "Groundbreaking Innovation" , type: "innovation" , content: [ { title: "Hierarchical Viewing Keys (HDVK)" ,
    novelty: "10/10" , desc: "Academic publication-worthy. First post-quantum deterministic viewing key system." ,
    impact: "Enables regulated privacy & compliance" }, { title: "Encrypted State Execution" , novelty: "9/10" ,
    desc: "Solves unsolved problem: smart contracts over fully encrypted state." ,
    impact: "Confidential DeFi & private computation" }, { title: "ShardBFT + zk-Finality" , novelty: "9/10" ,
    desc: "Novel consensus combining BFT, sharding, and recursive STARKs." ,
    impact: "Mobile devices validate entire chain" } ] }, { title: "Competitive Advantage" , type: "competition" ,
    content: [ { competitor: "Zcash" , advantage: "Post-quantum secure, 166× faster, smart contracts" , metrics:
    ["Quantum vulnerable", "<300 TPS" , "No contracts" ] }, { competitor: "Ethereum" ,
    advantage: "Native privacy, 666× faster base layer, quantum-resistant" , metrics: ["No privacy", "15 TPS"
    , "Quantum vulnerable" ] }, { competitor: "Monero" ,
    advantage: "Deterministic viewing keys, smart contracts, quantum-resistant" , metrics: ["No viewing
    keys", "No contracts" , "Quantum vulnerable" ] }, { competitor: "Secret Network" ,
    advantage: "No TEE dependency, post-quantum, 50× faster" , metrics: ["TEE required", "Classical crypto" , "~1K TPS"
    ] } ] }, { title: "Target Markets" , type: "market" , content: [ { segment: "Privacy-Focused DeFi" , tam: "$50B" ,
    users: "Institutional traders, dark pools, confidential trading" , pain: "$2B/year lost to MEV" }, {
    segment: "Post-Quantum Security" , tam: "$30B" ,
    users: "Government contracts, long-term value storage, institutional custody" ,
    pain: "Quantum computers threaten all ECC-based chains" }, { segment: "Regulated Privacy" , tam: "$20B" ,
    users: "Financial institutions, compliance officers, auditors" , pain: "Need privacy with selective disclosure" }, {
    segment: "Cross-Chain Privacy" , tam: "$15B" , users: "Multi-chain portfolio managers, privacy protocol developers"
    , pain: "No private bridges between major chains" } ] }, { title: "Business Model & Token Economics" ,
    type: "economics" , content: { supply: "1B ECLIPT (1.3B with tail inflation)" , revenue:
    [ "Transaction fees: 70% burned (deflationary), 30% to validators" , "Bridge fees: 0.1% of bridged value"
    , "MEV redistribution: Fair sequencing auction revenue" ],
    staking: "60% target stake ratio, 8% APY at target, 100% slashing for attacks" } }, { title: "Traction & Milestones"
    , type: "traction" , content: [ { milestone: "Technical Design" , status: "Complete" , date: "Q4 2024" ,
    desc: "25+ specification documents, 95% architecture complete" }, { milestone: "Core Validation" ,
    status: "In Progress" , date: "Q1 2025" , desc: "STARK benchmarks, encrypted execution POC" }, {
    milestone: "Testnet Launch" , status: "Planned" , date: "Q3 2025" ,
    desc: "4 shards, 5-10K TPS target, mobile light clients" }, { milestone: "Mainnet Launch" , status: "Planned" ,
    date: "Q1 2026" , desc: "Security audits complete, 50K TPS target" } ] }, { title: "Go-to-Market Strategy" ,
    type: "gtm" , content: [ { phase: "Phase 1: Developer Ecosystem (Q2-Q3 2025)" , items: ["SDK releases (Rust, Python,
    JS)", "Developer grants program" , "Hackathons & bounties" ] }, {
    phase: "Phase 2: Strategic Partnerships (Q3-Q4 2025)" , items: ["Major wallet integrations
    (3+)", "DEX protocol partnerships" , "Institutional pilot programs" ] }, {
    phase: "Phase 3: Mainnet Launch (Q1 2026)" , items: ["Exchange listings (CEX + DEX)", "Liquidity mining programs"
    , "Enterprise onboarding" ] } ] }, { title: "Financial Projections" , type: "projections" , content: { conservative:
    { year: "Year 1" , users: "10K-50K" , txVolume: "100K-500K daily" , marketCap: "$100M-$500M" , tvl: "$10M-$50M" },
    growth: { year: "Year 3" , users: "500K-1M" , txVolume: "5M-20M daily" , marketCap: "$2B-$10B" , tvl: "$500M-$2B" }
    } }, { title: "The Ask" , type: "ask" , content: { amount: "$10-20M Series A" , use: [ { item: "Engineering (60%)" ,
    amount: "$6-12M" , desc: "10-15 elite engineers: cryptographers, distributed systems, Rust developers" }, {
    item: "Security & Audits (15%)" , amount: "$1.5-3M" ,
    desc: "Multiple independent audits, formal verification, bug bounty program" }, {
    item: "Operations & Infrastructure (15%)" , amount: "$1.5-3M" ,
    desc: "Cloud infrastructure, testing environments, monitoring systems" }, { item: "Business Development (10%)" ,
    amount: "$1-2M" , desc: "Partnerships, exchange listings, market making, legal & compliance" } ],
    runway: "24-30 months to mainnet launch" } }, { title: "Why Now?" , type: "timing" , content: [ {
    reason: "NIST post-quantum standards finalized (2024)" , impact: "ML-KEM/ML-DSA now production-ready" }, {
    reason: "Quantum computing advancing rapidly" , impact: "IBM 1,121-qubit system, NISQ era ending soon" }, {
    reason: "Privacy regulations tightening globally" , impact: "GDPR, MiCA requiring privacy-preserving solutions" }, {
    reason: "MEV crisis in DeFi" , impact: "$2B+ extracted annually, institutional adoption blocked" }, {
    reason: "Mobile-first crypto adoption" , impact: "99% of users need light client solutions" } ] }, {
    title: "Team Requirements" , type: "team" , content: { needed: [ { role: "Co-Founder / CTO" ,
    profile: "PhD in cryptography or distributed systems, 5+ years blockchain experience" }, {
    role: "Lead Cryptographer" ,
    profile: "Post-quantum crypto expert, academic publications in lattice-based cryptography" }, {
    role: "Protocol Engineers (3-4)" , profile: "Expert Rust developers with consensus mechanism experience" }, {
    role: "Security Lead" , profile: "10+ years security, formal verification background" }, {
    role: "Business Development Lead" , profile: "Web3 institutional relationships, fundraising experience" } ],
    advisors: "Seeking advisors from Zcash, StarkWare, Ethereum Foundation" } }, { title: "Risk Mitigation" ,
    type: "risks" , content: [ { risk: "STARK proof generation too slow" ,
    mitigation: "Phase 0 validation with real benchmarks before full implementation" , status: "Q1 2025" }, {
    risk: "Encrypted state execution unsolved" , mitigation: "3 execution models in parallel, select best performing" ,
    status: "Q1 2025" }, { risk: "Post-quantum crypto overhead" ,
    mitigation: "Tiered execution model (public/encrypted/max-privacy)" , status: "In design" }, {
    risk: "Developer adoption challenge" , mitigation: "Extensive SDK support, familiar WASM contracts, generous grants"
    , status: "Q2 2025" }, { risk: "Market timing / competition" ,
    mitigation: "First-mover advantage, novel IP (HDVK patent pending)" , status: "Ongoing" } ] }, {
    title: "Exit Opportunities" , type: "exit" , content: [ { scenario: "Strategic Acquisition" , potential: "$500M-$2B"
    ,
    acquirers: "Major L1s (Ethereum Foundation, Solana Labs), Privacy-focused protocols, Enterprise blockchain companies"
    , timeline: "3-5 years" }, { scenario: "Token Public Sale" , potential: "$2B-$10B FDV" ,
    desc: "Mainnet launch with 10K+ active users, institutional adoption validated" , timeline: "2-3 years" }, {
    scenario: "Continued Independence" , potential: "$10B+ FDV" ,
    desc: "Become dominant post-quantum privacy L1, capture significant DeFi market share" , timeline: "5-7 years" } ]
    }, { title: "Contact & Next Steps" , type: "closing" , content: {
    cta: "Join us in building the quantum-resistant future of private blockchain technology" , next:
    [ "Technical deep-dive with engineering team" , "Validation phase results review (Q1 2025)"
    , "Partnership discussions with strategic investors" , "Token sale structure & terms discussion" ], contact: {
    website: "ecliptica.io" , email: "founders@ecliptica.io" , docs: "docs.ecliptica.io" } } } ]; const nextSlide=()=>
    setCurrentSlide((prev) => Math.min(prev + 1, slides.length - 1));
    const prevSlide = () => setCurrentSlide((prev) => Math.max(prev - 1, 0));

    const renderSlide = (slide) => {
    switch(slide.type) {
    case 'cover':
    return (
    <div
        className="flex flex-col items-center justify-center h-full bg-gradient-to-br from-indigo-900 via-purple-900 to-indigo-800 text-white">
        <div
            className="text-7xl font-bold mb-6 bg-clip-text text-transparent bg-gradient-to-r from-blue-200 to-purple-200">
            {slide.title}
        </div>
        <div className="text-3xl mb-8 text-purple-200">{slide.subtitle}</div>
        <div className="text-xl text-purple-300 max-w-3xl text-center">{slide.content}</div>
    </div>
    );

    case 'problem':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="grid grid-cols-2 gap-8">
            {slide.content.map((item, idx) => (
            <div key={idx} className="bg-red-50 border-l-4 border-red-500 p-6 rounded-r-lg">
                <item.icon className="w-12 h-12 text-red-600 mb-4" />
                <p className="text-lg text-gray-800 mb-3">{item.text}</p>
                <p className="text-2xl font-bold text-red-600">{item.stat}</p>
            </div>
            ))}
        </div>
    </div>
    );

    case 'solution':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="grid grid-cols-2 gap-8">
            {slide.content.map((item, idx) => (
            <div key={idx}
                className="bg-gradient-to-br from-green-50 to-emerald-50 p-8 rounded-xl border-2 border-green-200">
                <item.icon className="w-14 h-14 text-green-600 mb-4" />
                <h3 className="text-2xl font-bold text-gray-900 mb-3">{item.title}</h3>
                <p className="text-lg text-gray-700">{item.desc}</p>
            </div>
            ))}
        </div>
    </div>
    );

    case 'innovation':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-8 text-indigo-900">{slide.title}</h1>
        <p className="text-xl text-gray-600 mb-10">Novel IP worthy of academic publication</p>
        <div className="space-y-6">
            {slide.content.map((item, idx) => (
            <div key={idx} className="bg-white border-2 border-indigo-200 rounded-xl p-6 shadow-lg">
                <div className="flex items-start justify-between mb-3">
                    <h3 className="text-2xl font-bold text-indigo-900">{item.title}</h3>
                    <span
                        className="bg-gradient-to-r from-yellow-400 to-orange-400 text-white px-4 py-2 rounded-full font-bold">
                        Novelty: {item.novelty}
                    </span>
                </div>
                <p className="text-gray-700 mb-3 text-lg">{item.desc}</p>
                <p className="text-indigo-600 font-semibold">Impact: {item.impact}</p>
            </div>
            ))}
        </div>
    </div>
    );

    case 'competition':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="space-y-6">
            {slide.content.map((item, idx) => (
            <div key={idx} className="bg-white rounded-xl border-2 border-gray-200 p-6 shadow-md">
                <div className="flex items-center justify-between mb-4">
                    <h3 className="text-2xl font-bold text-gray-900">vs. {item.competitor}</h3>
                    <Award className="w-10 h-10 text-green-600" />
                </div>
                <p className="text-lg text-green-700 font-semibold mb-3">✓ {item.advantage}</p>
                <div className="flex gap-4 flex-wrap">
                    {item.metrics.map((metric, midx) => (
                    <span key={midx} className="bg-red-100 text-red-700 px-3 py-1 rounded-full text-sm">
                        ✗ {metric}
                    </span>
                    ))}
                </div>
            </div>
            ))}
        </div>
    </div>
    );

    case 'market':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-8 text-indigo-900">{slide.title}</h1>
        <p className="text-2xl text-gray-600 mb-10">Total Addressable Market: $115B+</p>
        <div className="grid grid-cols-2 gap-6">
            {slide.content.map((item, idx) => (
            <div key={idx}
                className="bg-gradient-to-br from-blue-50 to-indigo-50 p-6 rounded-xl border-2 border-indigo-200">
                <div className="flex items-center justify-between mb-4">
                    <h3 className="text-2xl font-bold text-indigo-900">{item.segment}</h3>
                    <span className="bg-indigo-600 text-white px-4 py-2 rounded-full font-bold">{item.tam}</span>
                </div>
                <p className="text-gray-700 mb-3">{item.users}</p>
                <p className="text-red-600 font-semibold">Pain: {item.pain}</p>
            </div>
            ))}
        </div>
    </div>
    );

    case 'economics':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="space-y-8">
            <div className="bg-gradient-to-r from-purple-50 to-indigo-50 p-8 rounded-xl border-2 border-purple-300">
                <h3 className="text-2xl font-bold text-purple-900 mb-4">Token Supply</h3>
                <p className="text-xl text-gray-800">{slide.content.supply}</p>
            </div>
            <div className="bg-gradient-to-r from-green-50 to-emerald-50 p-8 rounded-xl border-2 border-green-300">
                <h3 className="text-2xl font-bold text-green-900 mb-4">Revenue Streams</h3>
                <ul className="space-y-3">
                    {slide.content.revenue.map((rev, idx) => (
                    <li key={idx} className="text-lg text-gray-800 flex items-start">
                        <DollarSign className="w-6 h-6 text-green-600 mr-2 flex-shrink-0 mt-1" />
                        {rev}
                    </li>
                    ))}
                </ul>
            </div>
            <div className="bg-gradient-to-r from-blue-50 to-cyan-50 p-8 rounded-xl border-2 border-blue-300">
                <h3 className="text-2xl font-bold text-blue-900 mb-4">Staking Economics</h3>
                <p className="text-lg text-gray-800">{slide.content.staking}</p>
            </div>
        </div>
    </div>
    );

    case 'traction':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="relative">
            <div className="absolute left-8 top-0 bottom-0 w-1 bg-indigo-200"></div>
            <div className="space-y-8">
                {slide.content.map((item, idx) => (
                <div key={idx} className="relative pl-20">
                    <div className={`absolute left-4 w-8 h-8 rounded-full border-4 ${ item.status==='Complete'
                        ? 'bg-green-500 border-green-200' : item.status==='In Progress' ? 'bg-blue-500 border-blue-200'
                        : 'bg-gray-300 border-gray-200' }`}></div>
                    <div className={`p-6 rounded-xl border-2 ${ item.status==='Complete'
                        ? 'bg-green-50 border-green-300' : item.status==='In Progress' ? 'bg-blue-50 border-blue-300'
                        : 'bg-gray-50 border-gray-300' }`}>
                        <div className="flex items-center justify-between mb-2">
                            <h3 className="text-xl font-bold text-gray-900">{item.milestone}</h3>
                            <span className="text-sm font-semibold text-gray-600">{item.date}</span>
                        </div>
                        <p className="text-gray-700 mb-2">{item.desc}</p>
                        <span className={`inline-block px-3 py-1 rounded-full text-sm font-semibold ${
                            item.status==='Complete' ? 'bg-green-200 text-green-800' : item.status==='In Progress'
                            ? 'bg-blue-200 text-blue-800' : 'bg-gray-200 text-gray-800' }`}>
                            {item.status}
                        </span>
                    </div>
                </div>
                ))}
            </div>
        </div>
    </div>
    );

    case 'gtm':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="space-y-8">
            {slide.content.map((phase, idx) => (
            <div key={idx}
                className="bg-gradient-to-r from-indigo-50 to-purple-50 p-8 rounded-xl border-2 border-indigo-300">
                <h3 className="text-2xl font-bold text-indigo-900 mb-4">{phase.phase}</h3>
                <ul className="space-y-2">
                    {phase.items.map((item, iidx) => (
                    <li key={iidx} className="text-lg text-gray-800 flex items-center">
                        <Target className="w-5 h-5 text-indigo-600 mr-3" />
                        {item}
                    </li>
                    ))}
                </ul>
            </div>
            ))}
        </div>
    </div>
    );

    case 'projections':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="grid grid-cols-2 gap-8">
            <div className="bg-gradient-to-br from-blue-50 to-cyan-50 p-8 rounded-xl border-2 border-blue-300">
                <h3 className="text-3xl font-bold text-blue-900 mb-6">Conservative ({slide.content.conservative.year})
                </h3>
                <div className="space-y-4">
                    <div>
                        <p className="text-sm text-gray-600 mb-1">Active Users</p>
                        <p className="text-2xl font-bold text-gray-900">{slide.content.conservative.users}</p>
                    </div>
                    <div>
                        <p className="text-sm text-gray-600 mb-1">Daily Transactions</p>
                        <p className="text-2xl font-bold text-gray-900">{slide.content.conservative.txVolume}</p>
                    </div>
                    <div>
                        <p className="text-sm text-gray-600 mb-1">Market Cap</p>
                        <p className="text-2xl font-bold text-blue-600">{slide.content.conservative.marketCap}</p>
                    </div>
                    <div>
                        <p className="text-sm text-gray-600 mb-1">TVL</p>
                        <p className="text-2xl font-bold text-blue-600">{slide.content.conservative.tvl}</p>
                    </div>
                </div>
            </div>

            <div className="bg-gradient-to-br from-green-50 to-emerald-50 p-8 rounded-xl border-2 border-green-300">
                <h3 className="text-3xl font-bold text-green-900 mb-6">Growth ({slide.content.growth.year})</h3>
                <div className="space-y-4">
                    <div>
                        <p className="text-sm text-gray-600 mb-1">Active Users</p>
                        <p className="text-2xl font-bold text-gray-900">{slide.content.growth.users}</p>
                    </div>
                    <div>
                        <p className="text-sm text-gray-600 mb-1">Daily Transactions</p>
                        <p className="text-2xl font-bold text-gray-900">{slide.content.growth.txVolume}</p>
                    </div>
                    <div>
                        <p className="text-sm text-gray-600 mb-1">Market Cap</p>
                        <p className="text-2xl font-bold text-green-600">{slide.content.growth.marketCap}</p>
                    </div>
                    <div>
                        <p className="text-sm text-gray-600 mb-1">TVL</p>
                        <p className="text-2xl font-bold text-green-600">{slide.content.growth.tvl}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    );

    case 'ask':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-8 text-indigo-900">{slide.title}</h1>
        <div className="bg-gradient-to-r from-purple-100 to-indigo-100 p-8 rounded-2xl border-4 border-indigo-400 mb-8">
            <p className="text-4xl font-bold text-indigo-900 mb-4">{slide.content.amount}</p>
            <p className="text-xl text-gray-800">{slide.content.runway}</p>
        </div>
        <h3 className="text-2xl font-bold text-gray-900 mb-6">Use of Funds</h3>
        <div className="space-y-4">
            {slide.content.use.map((item, idx) => (
            <div key={idx} className="bg-white p-6 rounded-xl border-2 border-gray-200">
                <div className="flex justify-between items-start mb-2">
                    <h4 className="text-xl font-bold text-gray-900">{item.item}</h4>
                    <span className="text-xl font-bold text-indigo-600">{item.amount}</span>
                </div>
                <p className="text-gray-700">{item.desc}</p>
            </div>
            ))}
        </div>
    </div>
    );

    case 'timing':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="space-y-6">
            {slide.content.map((item, idx) => (
            <div key={idx}
                className="bg-gradient-to-r from-orange-50 to-red-50 p-6 rounded-xl border-l-4 border-orange-500">
                <div className="flex items-start">
                    <Clock className="w-8 h-8 text-orange-600 mr-4 flex-shrink-0 mt-1" />
                    <div>
                        <h3 className="text-xl font-bold text-gray-900 mb-2">{item.reason}</h3>
                        <p className="text-lg text-gray-700">{item.impact}</p>
                    </div>
                </div>
            </div>
            ))}
        </div>
    </div>
    );

    case 'team':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="mb-8">
            <h3 className="text-2xl font-bold text-gray-900 mb-6">Key Positions to Fill</h3>
            <div className="space-y-4">
                {slide.content.needed.map((person, idx) => (
                <div key={idx} className="bg-white p-6 rounded-xl border-2 border-indigo-200">
                    <div className="flex items-center mb-2">
                        <Users className="w-6 h-6 text-indigo-600 mr-3" />
                        <h4 className="text-xl font-bold text-gray-900">{person.role}</h4>
                    </div>
                    <p className="text-gray-700">{person.profile}</p>
                </div>
                ))}
            </div>
        </div>
        <div className="bg-gradient-to-r from-purple-50 to-indigo-50 p-6 rounded-xl border-2 border-purple-300">
            <p className="text-lg text-gray-800"><strong>Advisors:</strong> {slide.content.advisors}</p>
        </div>
    </div>
    );

    case 'risks':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="space-y-6">
            {slide.content.map((item, idx) => (
            <div key={idx} className="bg-white p-6 rounded-xl border-2 border-gray-300 shadow-md">
                <div className="grid grid-cols-3 gap-4">
                    <div>
                        <p className="text-sm font-semibold text-red-600 mb-2">RISK</p>
                        <p className="text-lg text-gray-900">{item.risk}</p>
                    </div>
                    <div>
                        <p className="text-sm font-semibold text-green-600 mb-2">MITIGATION</p>
                        <p className="text-lg text-gray-900">{item.mitigation}</p>
                    </div>
                    <div>
                        <p className="text-sm font-semibold text-blue-600 mb-2">STATUS</p>
                        <p className="text-lg font-semibold text-blue-700">{item.status}</p>
                    </div>
                </div>
            </div>
            ))}
        </div>
    </div>
    );

    case 'exit':
    return (
    <div className="p-12">
        <h1 className="text-5xl font-bold mb-12 text-indigo-900">{slide.title}</h1>
        <div className="space-y-6">
            {slide.content.map((item, idx) => (
            <div key={idx}
                className="bg-gradient-to-r from-green-50 to-emerald-50 p-8 rounded-xl border-2 border-green-300">
                <div className="flex justify-between items-start mb-4">
                    <h3 className="text-2xl font-bold text-gray-900">{item.scenario}</h3>
                    <span className="text-3xl font-bold text-green-600">{item.potential}</span>
                </div>
                <p className="text-lg text-gray-800 mb-3">{item.desc || item.acquirers}</p>
                <p className="text-sm text-gray-600">Timeline: {item.timeline}</p>
            </div>
            ))}
        </div>
    </div>
    );

    case 'closing':
    return (
    <div className="p-12 flex flex-col justify-center h-full">
        <div className="text-center mb-12">
            <h1 className="text-5xl font-bold text-indigo-900 mb-6">{slide.title}</h1>
            <p className="text-3xl text-gray-700 mb-12 italic">"{slide.content.cta}"</p>
        </div>

        <div className="bg-gradient-to-r from-indigo-50 to-purple-50 p-8 rounded-xl border-2 border-indigo-300 mb-8">
            <h3 className="text-2xl font-bold text-indigo-900 mb-6">Next Steps</h3>
            <ul className="space-y-3">
                {slide.content.next.map((step, idx) => (
                <li key={idx} className="text-lg text-gray-800 flex items-center">
                    <span
                        className="w-8 h-8 rounded-full bg-indigo-600 text-white flex items-center justify-center mr-4 font-bold">
                        {idx + 1}
                    </span>
                    {step}
                </li>
                ))}
            </ul>
        </div>

        <div className="text-center bg-white p-6 rounded-xl border-2 border-gray-300">
            <p className="text-xl text-gray-800 mb-2"><strong>Website:</strong> {slide.content.contact.website}</p>
            <p className="text-xl text-gray-800 mb-2"><strong>Email:</strong> {slide.content.contact.email}</p>
            <p className="text-xl text-gray-800"><strong>Documentation:</strong> {slide.content.contact.docs}</p>
        </div>
    </div>
    );

    default:
    return <div className="p-12">
        <h1 className="text-4xl font-bold">{slide.title}</h1>
    </div>;
    }
    };

    return (
    <div className="w-full h-screen bg-gray-50 flex flex-col">
        <div className="flex-1 overflow-hidden">
            <div className="h-full">
                {renderSlide(slides[currentSlide])}
            </div>
        </div>

        <div className="bg-white border-t-2 border-gray-200 p-4">
            <div className="flex items-center justify-between max-w-7xl mx-auto">
                <button onClick={prevSlide} disabled={currentSlide===0}
                    className="flex items-center gap-2 px-6 py-3 bg-indigo-600 text-white rounded-lg font-semibold disabled:opacity-30 disabled:cursor-not-allowed hover:bg-indigo-700 transition">
                    <ChevronLeft className="w-5 h-5" />
                    Previous
                </button>

                <div className="flex items-center gap-3">
                    <span className="text-lg font-semibold text-gray-700">
                        {currentSlide + 1} / {slides.length}
                    </span>
                    <div className="flex gap-1">
                        {slides.map((_, idx) => (
                        <button key={idx} onClick={()=> setCurrentSlide(idx)}
                            className={`w-2 h-2 rounded-full transition ${
                            idx === currentSlide ? 'bg-indigo-600 w-8' : 'bg-gray-300'
                            }`}
                            />
                            ))}
                    </div>
                </div>

                <button onClick={nextSlide} disabled={currentSlide===slides.length - 1}
                    className="flex items-center gap-2 px-6 py-3 bg-indigo-600 text-white rounded-lg font-semibold disabled:opacity-30 disabled:cursor-not-allowed hover:bg-indigo-700 transition">
                    Next
                    <ChevronRight className="w-5 h-5" />
                </button>
            </div>
        </div>
    </div>
    );
    };

    export default PitchDeck;