import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type EntrantData = {
  name: string;
  owner: string;
  breed: string;
};

type ResultData = {
  place: number;
  name: string;
  owner: string;
  score: number;
  prize: number;
  message?: string;
};

type CompetitionData = {
  id: string;
  name: string;
  type: 'race' | 'show' | 'trial';
  state: 'registration' | 'in_progress' | 'finished';
  description: string;
  entryFee: number;
  prizePool: number;
  maxEntrants: number;
  minEntrants: number;
  currentEntrants: number;
  timeRemaining: number;
  entrants: EntrantData[];
  results: ResultData[];
};

type UserHorse = {
  ref: string;
  name: string;
  breed: string;
  speed: number;
  intelligence: number;
  temperament: number;
};

type Data = {
  activeCompetitions: CompetitionData[];
  competitionHistory: CompetitionData[];
  userHorses: UserHorse[];
};

const getCompetitionIcon = (type: string) => {
  switch (type) {
    case 'race':
      return 'bolt';
    case 'show':
      return 'heart';
    case 'trial':
      return 'brain';
    default:
      return 'horse';
  }
};

const getCompetitionColor = (type: string) => {
  switch (type) {
    case 'race':
      return '#ffcc00';
    case 'show':
      return '#ff69b4';
    case 'trial':
      return '#00ccff';
    default:
      return '#888888';
  }
};

const formatTime = (deciseconds: number) => {
  const seconds = Math.floor(deciseconds / 10);
  const minutes = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${minutes}:${secs.toString().padStart(2, '0')}`;
};

const CompetitionCard = (props: {
  competition: CompetitionData;
  userHorses: UserHorse[];
  onEnter: (compId: string, horseRef: string) => void;
  onWithdraw: (compId: string, horseRef: string) => void;
}) => {
  const { competition, userHorses, onEnter, onWithdraw } = props;
  const [selectedHorse, setSelectedHorse] = useState<string | null>(null);

  const isRegistrationOpen = competition.state === 'registration';
  const isInProgress = competition.state === 'in_progress';
  const isFinished = competition.state === 'finished';

  // Check which of user's horses are already entered
  const enteredHorseNames = competition.entrants.map((e) => e.name);
  const availableHorses = userHorses.filter(
    (h) => !enteredHorseNames.includes(h.name),
  );
  const userEnteredHorses = userHorses.filter((h) =>
    enteredHorseNames.includes(h.name),
  );

  return (
    <Section
      title={
        <Stack align="center">
          <Stack.Item>
            <Icon
              name={getCompetitionIcon(competition.type)}
              color={getCompetitionColor(competition.type)}
            />
          </Stack.Item>
          <Stack.Item ml={1}>{competition.name}</Stack.Item>
          <Stack.Item ml={1} color="label">
            ({competition.type.toUpperCase()})
          </Stack.Item>
        </Stack>
      }
      buttons={
        <>
          {isRegistrationOpen && (
            <Box color="good">
              <Icon name="clock" mr={1} />
              {formatTime(competition.timeRemaining)}
            </Box>
          )}
          {isInProgress && (
            <Box color="average">
              <Icon name="running" mr={1} />
              In Progress
            </Box>
          )}
          {isFinished && (
            <Box color="label">
              <Icon name="flag-checkered" mr={1} />
              Finished
            </Box>
          )}
        </>
      }
    >
      {/* Description */}
      <Box color="label" fontSize="12px" mb={1}>
        {competition.description}
      </Box>

      {/* Stats */}
      <Stack mb={1}>
        <Stack.Item grow>
          <Box>
            <Icon name="users" mr={1} />
            Entrants: {competition.currentEntrants}/{competition.maxEntrants}
          </Box>
          <ProgressBar
            value={competition.currentEntrants / competition.maxEntrants}
            color={
              competition.currentEntrants >= competition.minEntrants
                ? 'good'
                : 'average'
            }
          />
        </Stack.Item>
        <Stack.Item basis="120px" ml={2}>
          <Box color="label">Entry Fee:</Box>
          <Box bold color="gold">
            ${competition.entryFee}
          </Box>
        </Stack.Item>
        <Stack.Item basis="120px">
          <Box color="label">Prize Pool:</Box>
          <Box bold color="green">
            ${competition.prizePool}
          </Box>
        </Stack.Item>
      </Stack>

      {/* Entrants list */}
      {competition.entrants.length > 0 && (
        <Box mb={1}>
          <Box bold mb={0.5}>
            Current Entrants:
          </Box>
          <Box>
            {competition.entrants
              .map((entrant) => `${entrant.name} (${entrant.breed})`)
              .join(', ')}
          </Box>
        </Box>
      )}

      {/* Results (if finished) */}
      {isFinished && competition.results.length > 0 && (
        <Box>
          <Box bold mb={0.5}>
            Results:
          </Box>
          <Table>
            <Table.Row header>
              <Table.Cell>Place</Table.Cell>
              <Table.Cell>Horse</Table.Cell>
              <Table.Cell>Owner</Table.Cell>
              <Table.Cell>Score</Table.Cell>
              <Table.Cell>Prize</Table.Cell>
            </Table.Row>
            {competition.results.map((result, idx) => (
              <Table.Row key={idx}>
                <Table.Cell>#{result.place}</Table.Cell>
                <Table.Cell bold>{result.name}</Table.Cell>
                <Table.Cell>{result.owner}</Table.Cell>
                <Table.Cell>{result.score}</Table.Cell>
                <Table.Cell>
                  {result.prize > 0 ? `$${result.prize}` : '-'}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Box>
      )}

      {/* Entry controls */}
      {isRegistrationOpen && userHorses.length > 0 && (
        <Box mt={1}>
          <Stack align="center">
            {availableHorses.length > 0 && (
              <>
                <Stack.Item grow>
                  <Dropdown
                    width="100%"
                    selected={selectedHorse}
                    options={availableHorses.map((h) => ({
                      value: h.ref,
                      displayText: `${h.name} (${h.breed}) - Spd:${h.speed} Int:${h.intelligence} Tmp:${h.temperament}`,
                    }))}
                    onSelected={(val) => setSelectedHorse(val as string)}
                    placeholder="Select a horse to enter..."
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="plus"
                    color="good"
                    disabled={!selectedHorse}
                    onClick={() => {
                      if (selectedHorse) {
                        onEnter(competition.id, selectedHorse);
                        setSelectedHorse(null);
                      }
                    }}
                  >
                    Enter (${competition.entryFee})
                  </Button>
                </Stack.Item>
              </>
            )}
            {userEnteredHorses.length > 0 && (
              <Stack.Item>
                <Dropdown
                  color="bad"
                  icon="times"
                  displayText="Withdraw..."
                  selected={null}
                  options={userEnteredHorses.map((h) => ({
                    value: h.ref,
                    displayText: h.name,
                  }))}
                  onSelected={(val) =>
                    onWithdraw(competition.id, val as string)
                  }
                />
              </Stack.Item>
            )}
          </Stack>
        </Box>
      )}

      {isRegistrationOpen && userHorses.length === 0 && (
        <Box color="label" italic mt={1}>
          You don&apos;t own any horses to enter.
        </Box>
      )}
    </Section>
  );
};

export const HorseCompetitionBoard = () => {
  const { act, data } = useBackend<Data>();
  const { activeCompetitions, competitionHistory, userHorses } = data;
  const [activeTab, setActiveTab] = useState(0);

  const handleEnter = (compId: string, horseRef: string) => {
    act('enter_competition', { competition_id: compId, horse_ref: horseRef });
  };

  const handleWithdraw = (compId: string, horseRef: string) => {
    act('withdraw_competition', {
      competition_id: compId,
      horse_ref: horseRef,
    });
  };

  // Separate active competitions by state
  const registrationOpen = activeCompetitions.filter(
    (c) => c.state === 'registration',
  );
  const inProgress = activeCompetitions.filter(
    (c) => c.state === 'in_progress',
  );
  const actuallyActive = registrationOpen.length + inProgress.length;

  return (
    <Window width={700} height={650}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab selected={activeTab === 0} onClick={() => setActiveTab(0)}>
            <Icon name="flag" mr={1} />
            Active Competitions ({actuallyActive})
          </Tabs.Tab>
          <Tabs.Tab selected={activeTab === 1} onClick={() => setActiveTab(1)}>
            <Icon name="history" mr={1} />
            Recent Results ({competitionHistory.length})
          </Tabs.Tab>
          <Tabs.Tab selected={activeTab === 2} onClick={() => setActiveTab(2)}>
            <Icon name="horse" mr={1} />
            My Horses ({userHorses.length})
          </Tabs.Tab>
        </Tabs>

        {activeTab === 0 && (
          <Box mt={1}>
            {registrationOpen.length > 0 && (
              <Section title="Open for Registration">
                {registrationOpen.map((comp) => (
                  <CompetitionCard
                    key={comp.id}
                    competition={comp}
                    userHorses={userHorses}
                    onEnter={handleEnter}
                    onWithdraw={handleWithdraw}
                  />
                ))}
              </Section>
            )}

            {inProgress.length > 0 && (
              <Section title="In Progress">
                {inProgress.map((comp) => (
                  <CompetitionCard
                    key={comp.id}
                    competition={comp}
                    userHorses={userHorses}
                    onEnter={handleEnter}
                    onWithdraw={handleWithdraw}
                  />
                ))}
              </Section>
            )}

            {activeCompetitions.length === 0 && (
              <Box color="label" textAlign="center" mt={2}>
                No active competitions. Check back soon!
              </Box>
            )}
          </Box>
        )}

        {activeTab === 1 && (
          <Box mt={1}>
            <Section title="Recent Competition Results">
              {competitionHistory.length > 0 ? (
                competitionHistory.map((comp) => (
                  <CompetitionCard
                    key={comp.id}
                    competition={comp}
                    userHorses={userHorses}
                    onEnter={handleEnter}
                    onWithdraw={handleWithdraw}
                  />
                ))
              ) : (
                <Box color="label" textAlign="center" mt={2}>
                  No competition history yet.
                </Box>
              )}
            </Section>
          </Box>
        )}

        {activeTab === 2 && (
          <Box mt={1}>
            <Section title="Your Horses">
              {userHorses.length > 0 ? (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Name</Table.Cell>
                    <Table.Cell>Breed</Table.Cell>
                    <Table.Cell>Speed</Table.Cell>
                    <Table.Cell>Intelligence</Table.Cell>
                    <Table.Cell>Temperament</Table.Cell>
                    <Table.Cell>Best For</Table.Cell>
                  </Table.Row>
                  {userHorses.map((horse, idx) => {
                    // Determine what competition type this horse is best suited for
                    const raceScore =
                      horse.speed * 2 + horse.intelligence * 0.5;
                    const showScore =
                      (100 - horse.temperament) * 2 + horse.intelligence * 0.5;
                    const trialScore =
                      horse.intelligence * 2 + (100 - horse.temperament) * 0.5;
                    const bestFor =
                      raceScore >= showScore && raceScore >= trialScore
                        ? 'Race'
                        : showScore >= trialScore
                          ? 'Show'
                          : 'Trial';
                    return (
                      <Table.Row key={idx}>
                        <Table.Cell bold>{horse.name}</Table.Cell>
                        <Table.Cell>{horse.breed}</Table.Cell>
                        <Table.Cell>{horse.speed}</Table.Cell>
                        <Table.Cell>{horse.intelligence}</Table.Cell>
                        <Table.Cell>{horse.temperament}</Table.Cell>
                        <Table.Cell>{bestFor}</Table.Cell>
                      </Table.Row>
                    );
                  })}
                </Table>
              ) : (
                <Box color="label" textAlign="center" mt={4}>
                  You don&apos;t own any horses yet. Tame a horse by feeding it
                  apples, carrots, or sugarcane!
                </Box>
              )}
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
