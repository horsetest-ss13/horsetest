import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BreedInfo = {
  name: string;
  description: string;
  rarity: number;
  idealTemperament: number;
  idealIntelligence: number;
  idealSpeed: number;
};

type HorseData = {
  name: string;
  gender: string;
  health: number;
  maxHealth: number;
  temperament: number;
  maxTemperament: number;
  intelligence: number;
  maxIntelligence: number;
  speed: number;
  maxSpeed: number;
  age: number;
  retired: boolean;
  maxAge: number;
  pregnant: boolean;
  canBreed: boolean;
  breed?: BreedInfo;
  owner: string | null;
  isOwner: boolean;
};

export const HorseMenu = () => {
  const { act, data } = useBackend<HorseData>();

  const {
    name,
    gender,
    health,
    maxHealth,
    temperament,
    maxTemperament,
    intelligence,
    maxIntelligence,
    speed,
    maxSpeed,
    age,
    retired,
    maxAge,
    pregnant,
    canBreed,
    breed,
    owner,
    isOwner,
  } = data;

  const getTemperamentLabel = (value: number) => {
    if (value < 30) return 'Very Calm';
    if (value < 60) return 'Moderate';
    return 'Spirited';
  };

  const getIntelligenceLabel = (value: number) => {
    if (value < 30) return 'Simple';
    if (value < 60) return 'Average';
    return 'Clever';
  };

  const getSpeedLabel = (value: number) => {
    if (value < 30) return 'Slow';
    if (value < 60) return 'Moderate';
    return 'Fast';
  };

  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title={name}
              buttons={
                <Box color="label" fontSize="14px">
                  {gender}
                </Box>
              }
            >
              <LabeledList>
                {breed && (
                  <LabeledList.Item label="Breed">
                    {breed.name}{' '}
                    <Box as="span" color="label" fontSize="11px">
                      ({breed.rarity}/10)
                    </Box>
                  </LabeledList.Item>
                )}
                {owner && (
                  <LabeledList.Item
                    label="Owner"
                    color={isOwner ? 'good' : 'average'}
                  >
                    {owner}
                    {isOwner && ' (You)'}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Age">
                  {age} / {maxAge} years
                  {retired && (
                    <Box as="span" color="average" ml={1}>
                      (Retired)
                    </Box>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    value={health}
                    minValue={0}
                    maxValue={maxHealth}
                    ranges={{
                      good: [maxHealth * 0.6, Infinity],
                      average: [maxHealth * 0.3, maxHealth * 0.6],
                      bad: [-Infinity, maxHealth * 0.3],
                    }}
                  >
                    {health} / {maxHealth} HP
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Statistics">
              <LabeledList>
                <LabeledList.Item label="Temperament">
                  <ProgressBar
                    value={temperament}
                    minValue={0}
                    maxValue={maxTemperament}
                    color={
                      temperament < 30
                        ? 'green'
                        : temperament < 60
                          ? 'yellow'
                          : 'red'
                    }
                  >
                    {temperament} / {maxTemperament} (
                    {getTemperamentLabel(temperament)})
                  </ProgressBar>
                  {breed && (
                    <Box
                      fontSize="11px"
                      color={
                        Math.abs(temperament - breed.idealTemperament) < 10
                          ? 'good'
                          : Math.abs(temperament - breed.idealTemperament) < 20
                            ? 'average'
                            : 'bad'
                      }
                    >
                      Breed Ideal: {breed.idealTemperament}
                    </Box>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Intelligence">
                  <ProgressBar
                    value={intelligence}
                    minValue={0}
                    maxValue={maxIntelligence}
                    color="blue"
                  >
                    {intelligence} / {maxIntelligence} (
                    {getIntelligenceLabel(intelligence)})
                  </ProgressBar>
                  {breed && (
                    <Box
                      fontSize="11px"
                      color={
                        Math.abs(intelligence - breed.idealIntelligence) < 10
                          ? 'good'
                          : Math.abs(intelligence - breed.idealIntelligence) <
                              20
                            ? 'average'
                            : 'bad'
                      }
                    >
                      Breed Ideal: {breed.idealIntelligence}
                    </Box>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Speed">
                  <ProgressBar
                    value={speed}
                    minValue={0}
                    maxValue={maxSpeed}
                    color="purple"
                  >
                    {speed} / {maxSpeed} ({getSpeedLabel(speed)})
                  </ProgressBar>
                  {breed && (
                    <Box
                      fontSize="11px"
                      color={
                        Math.abs(speed - breed.idealSpeed) < 10
                          ? 'good'
                          : Math.abs(speed - breed.idealSpeed) < 20
                            ? 'average'
                            : 'bad'
                      }
                    >
                      Breed Ideal: {breed.idealSpeed}
                    </Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Breeding">
              {pregnant ? (
                <Box color="good" fontSize="16px" textAlign="center" p={1}>
                  🐴 This mare is pregnant!
                </Box>
              ) : (
                <Stack>
                  <Stack.Item grow>
                    <Button
                      fluid
                      icon="heart"
                      disabled={!canBreed}
                      onClick={() => act('breed')}
                      tooltip={
                        !canBreed
                          ? gender === 'Mare'
                            ? 'Already pregnant'
                            : 'Not ready to breed'
                          : 'Select a nearby mate'
                      }
                    >
                      Breed Horse
                    </Button>
                  </Stack.Item>
                </Stack>
              )}
              <Box mt={1} color="label" fontSize="12px">
                {gender === 'Stallion'
                  ? 'Find a mare to breed with nearby.'
                  : 'Find a stallion to breed with nearby.'}
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
