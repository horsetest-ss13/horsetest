import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type HorseData = {
  name: string;
  gender: string;
  breed: string;
  temperament: number;
  intelligence: number;
  speed: number;
  age: number;
  wasBorn?: boolean;
  retired?: boolean;
  storedTime: number;
  retiredTime?: number;
};

type SlotData = {
  slot: number;
  occupied: boolean;
  horse: HorseData | null;
};

type NearbyHorse = {
  ref: string;
  name: string;
  breed: string;
  age: number;
};

type Data = {
  ckey: string;
  slots: SlotData[];
  nearbyHorses: NearbyHorse[];
  retiredHorses: HorseData[];
  maxRetirementAge: number;
  error?: string;
};

const HorseSlot = (props: {
  slot: SlotData;
  nearbyHorses: NearbyHorse[];
  maxRetirementAge: number;
  onStore: (slot: number, horseRef: string) => void;
  onRetrieve: (slot: number) => void;
  onClear: (slot: number) => void;
}) => {
  const { slot, nearbyHorses, maxRetirementAge, onStore, onRetrieve, onClear } =
    props;
  const [selectedHorse, setSelectedHorse] = useState<string | null>(null);

  return (
    <Section
      title={`Slot ${slot.slot}`}
      buttons={
        slot.occupied && (
          <Button
            icon="times"
            color="bad"
            onClick={() => onClear(slot.slot)}
            tooltip="Permanently delete this horse from storage"
          >
            Clear
          </Button>
        )
      }
    >
      {slot.occupied && slot.horse ? (
        <Box>
          <LabeledList>
            <LabeledList.Item label="Name">{slot.horse.name}</LabeledList.Item>
            <LabeledList.Item label="Gender">
              {slot.horse.gender}
            </LabeledList.Item>
            <LabeledList.Item label="Breed">
              {slot.horse.breed}
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              {slot.horse.age} / {maxRetirementAge}
            </LabeledList.Item>
            <LabeledList.Item label="Speed">
              {slot.horse.speed}
            </LabeledList.Item>
            <LabeledList.Item label="Intelligence">
              {slot.horse.intelligence}
            </LabeledList.Item>
            <LabeledList.Item label="Temperament">
              {slot.horse.temperament}
            </LabeledList.Item>
          </LabeledList>
          <Box mt={1}>
            <Button
              fluid
              icon="download"
              color="good"
              onClick={() => onRetrieve(slot.slot)}
            >
              Retrieve {slot.horse.name}
            </Button>
          </Box>
        </Box>
      ) : (
        <Box>
          <Box color="label" mb={1}>
            Empty slot - store a horse here!
          </Box>
          {nearbyHorses.length > 0 ? (
            <Stack>
              <Stack.Item grow>
                <Dropdown
                  width="100%"
                  selected={selectedHorse}
                  placeholder="Select a horse..."
                  options={nearbyHorses.map((h) => ({
                    value: h.ref,
                    displayText: `${h.name} (${h.breed}, age ${h.age})`,
                  }))}
                  onSelected={(val) => setSelectedHorse(val as string)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="upload"
                  color="good"
                  disabled={!selectedHorse}
                  onClick={() => {
                    if (selectedHorse) {
                      onStore(slot.slot, selectedHorse);
                      setSelectedHorse(null);
                    }
                  }}
                >
                  Store
                </Button>
              </Stack.Item>
            </Stack>
          ) : (
            <Box color="average">
              No owned horses nearby. Bring your horse within 3 tiles.
            </Box>
          )}
        </Box>
      )}
    </Section>
  );
};

export const HorseHoldie = () => {
  const { act, data } = useBackend<Data>();
  const { ckey, slots, nearbyHorses, retiredHorses, maxRetirementAge, error } =
    data;

  if (error) {
    return (
      <Window width={400} height={200}>
        <Window.Content>
          <Section title="Error">
            <Box color="bad">{error}</Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const handleStore = (slot: number, horseRef: string) => {
    act('store', { slot, horse_ref: horseRef });
  };

  const handleRetrieve = (slot: number) => {
    act('retrieve', { slot });
  };

  const handleClear = (slot: number) => {
    act('clear', { slot });
  };

  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        <Section title="Horse Holdie">
          <Box color="label" mb={1}>
            Store your horses here to save them between rounds! Horses age one
            year the first time they are retrieved each round and retire at age{' '}
            {maxRetirementAge}. Linked to your account: {ckey}
          </Box>
        </Section>

        {slots.map((slot) => (
          <HorseSlot
            key={slot.slot}
            slot={slot}
            nearbyHorses={nearbyHorses}
            maxRetirementAge={maxRetirementAge}
            onStore={handleStore}
            onRetrieve={handleRetrieve}
            onClear={handleClear}
          />
        ))}

        {retiredHorses?.length > 0 && (
          <Section title="Retired Horses">
            <Box color="label" mb={1}>
              These horses have finished their careers and are saved to your
              account.
            </Box>
            {retiredHorses.map((horse, index) => (
              <Section key={index} title={horse.name}>
                <LabeledList>
                  <LabeledList.Item label="Breed">
                    {horse.breed}
                  </LabeledList.Item>
                  <LabeledList.Item label="Gender">
                    {horse.gender}
                  </LabeledList.Item>
                  <LabeledList.Item label="Final Age">
                    {horse.age}
                  </LabeledList.Item>
                  <LabeledList.Item label="Speed">
                    {horse.speed}
                  </LabeledList.Item>
                  <LabeledList.Item label="Intelligence">
                    {horse.intelligence}
                  </LabeledList.Item>
                  <LabeledList.Item label="Temperament">
                    {horse.temperament}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
