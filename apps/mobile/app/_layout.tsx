import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="auto" />
      <Stack
        screenOptions={{
          headerStyle: {
            backgroundColor: '#0ea5e9',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}
      >
        <Stack.Screen
          name="index"
          options={{
            title: 'Early Help',
          }}
        />
        <Stack.Screen
          name="library"
          options={{
            title: 'Content Library',
          }}
        />
        <Stack.Screen
          name="glossary"
          options={{
            title: 'Glossary',
          }}
        />
        <Stack.Screen
          name="checklist"
          options={{
            title: 'Warning Signs Checklist',
          }}
        />
        <Stack.Screen
          name="help-navigator"
          options={{
            title: 'Help Navigator',
          }}
        />
      </Stack>
    </>
  );
}
