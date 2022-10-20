import '../styles/globals.css';
import '@rainbow-me/rainbowkit/styles.css';
import type { AppProps } from 'next/app';
import { RainbowKitProvider, getDefaultWallets } from '@rainbow-me/rainbowkit';
import { chain, configureChains, createClient, WagmiConfig } from 'wagmi';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { publicProvider } from 'wagmi/providers/public';
import { createTheme, NextUIProvider } from "@nextui-org/react"
import { ThemeProvider as NextThemesProvider } from 'next-themes';

// 2. Call `createTheme` and pass your custom values

// https://coolors.co/65524d-817e9f-7fc29b-b5ef8a-d7f171
// #535878, #9db0ce, #b8d8e3, #fee1dd, #e9c2c5, #cea0aa
const lightTheme = createTheme({
  type: 'light',
  theme: {
    colors: {
      primaryLight: '$gray900',
      primaryLightHover: '$gray800',
      primaryLightActive: '$gray700',
      primaryLightContrast: '$gray600',
      primary: '#gray900',
      primaryBorder: '$gray300',
      primaryBorderHover: '$gray300',
      primarySolidHover: '$gray400',
      primarySolidContrast: '$white',
      primaryShadow: '$gray900',
    }, // optional
  }
})

// https://coolors.co/231c35-242039-2a2b47-484564-5b5271-6e5774
// #231c35, #242039, #2a2b47, #484564, #5b5271, #6E5774
const darkTheme = createTheme({
  type: 'dark',
  theme: {
    colors: {
      primaryLight: '#A28BA7',
      primaryLightHover: '#987F9F',
      primaryLightActive: '#8F7396',
      primaryLightContrast: '#85698C',
      primary: '#6e5774',
      primaryBorder: '$gray300',
      primaryBorderHover: '$gray300',
      primarySolidHover: '#58465D',
      primarySolidContrast: '#4D3D51',
      primaryShadow: '#8F7396',
      secondary: '#484564',
      background: '#231c35',
      text: 'white'
    },
  }
})

const { chains, provider, webSocketProvider } = configureChains(
  [
    chain.mainnet,
    chain.polygon,
    chain.optimism,
    chain.arbitrum,
    ...(process.env.NEXT_PUBLIC_ENABLE_TESTNETS === 'true'
      ? [chain.goerli, chain.kovan, chain.rinkeby, chain.ropsten]
      : []),
  ],
  [
    alchemyProvider({
      // This is Alchemy's default API key.
      // You can get your own at https://dashboard.alchemyapi.io
      apiKey: '_gg7wSSi0KMBsdKnGVfHDueq6xMB9EkC',
    }),
    publicProvider(),
  ]
);

const { connectors } = getDefaultWallets({
  appName: 'RainbowKit App',
  chains,
});

const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
  webSocketProvider,
});

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <WagmiConfig client={wagmiClient}>
      <RainbowKitProvider chains={chains}>
        <NextThemesProvider
          defaultTheme="system"
          attribute="class"
          value={{
            light: lightTheme.className,
            dark: darkTheme.className
          }}
        >
          <NextUIProvider>
            <Component {...pageProps} />
          </NextUIProvider>
        </NextThemesProvider>
      </RainbowKitProvider>
    </WagmiConfig>
  );
}

export default MyApp;
