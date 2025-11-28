import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type HorseStats = {
  temperament: number;
  intelligence: number;
  speed: number;
};

type ChildInfo = {
  name: string;
  alive: boolean;
  gender: 'male' | 'female';
  stats: HorseStats;
};

type FamilyTreeNode = {
  fatherName: string;
  motherName: string;
  fatherAlive: boolean;
  motherAlive: boolean;
  fatherStats?: HorseStats;
  motherStats?: HorseStats;
  children?: ChildInfo[];
  depth: number;
  fatherTree?: FamilyTreeNode;
  motherTree?: FamilyTreeNode;
};

// Crusader Kings-style family tree node component
const FamilyNode = (props: {
  name: string;
  gender: 'male' | 'female';
  alive: boolean;
  current?: boolean;
  onClick?: () => void;
  expanded?: boolean;
  stats?: {
    temperament: number;
    intelligence: number;
    speed: number;
  };
}) => {
  const { name, gender, alive, current, onClick, expanded, stats } = props;
  const bgColor = current
    ? 'rgba(255, 215, 0, 0.3)'
    : gender === 'male'
      ? 'rgba(100, 150, 255, 0.2)'
      : 'rgba(255, 100, 150, 0.2)';
  const borderColor = current
    ? '#ffd700'
    : gender === 'male'
      ? '#6496ff'
      : '#ff6496';

  return (
    <Box>
      <Box
        onClick={onClick}
        style={{
          border: `2px solid ${borderColor}`,
          borderRadius: '8px',
          padding: '8px 12px',
          backgroundColor: bgColor,
          minWidth: '120px',
          cursor: onClick ? 'pointer' : 'default',
          textAlign: 'center',
          position: 'relative',
          opacity: alive ? 1 : 0.6,
        }}
      >
        <Box
          style={{
            fontSize: '11px',
            fontWeight: 'bold',
            color: gender === 'male' ? '#6496ff' : '#ff6496',
            marginBottom: '2px',
          }}
        >
          {gender === 'male' ? '♂' : '♀'}
        </Box>
        <Box
          style={{ fontSize: '13px', fontWeight: current ? 'bold' : 'normal' }}
        >
          {name}
        </Box>
        {!alive && (
          <Box
            style={{
              fontSize: '10px',
              color: '#888',
              marginTop: '2px',
              fontStyle: 'italic',
            }}
          >
            (deceased)
          </Box>
        )}
        {current && (
          <Box
            style={{
              fontSize: '9px',
              color: '#ffd700',
              marginTop: '2px',
              fontWeight: 'bold',
            }}
          >
            ⭐ YOU
          </Box>
        )}
      </Box>

      {/* Expanded stats panel */}
      {expanded && stats && (
        <Box
          mt={1}
          p={1}
          style={{
            backgroundColor: 'rgba(0, 0, 0, 0.3)',
            borderRadius: '4px',
            fontSize: '11px',
            border: `1px solid ${borderColor}`,
          }}
        >
          <Box mb={0.5}>
            <strong>Temperament:</strong> {stats.temperament}
          </Box>
          <Box mb={0.5}>
            <strong>Intelligence:</strong> {stats.intelligence}
          </Box>
          <Box>
            <strong>Speed:</strong> {stats.speed}
          </Box>
        </Box>
      )}
    </Box>
  );
};

// Renders a generation row with connection lines
const GenerationRow = (props: {
  nodes: Array<{ name: string; gender: 'male' | 'female'; alive: boolean }>;
  generation: number;
}) => {
  const { nodes, generation } = props;

  return (
    <Box mb={2}>
      <Box
        style={{
          fontSize: '11px',
          color: '#888',
          marginBottom: '4px',
          textAlign: 'center',
        }}
      >
        Generation {generation === 0 ? 'Current' : `-${generation}`}
      </Box>
      <Stack justify="center" wrap>
        {nodes.map((node, index) => (
          <Stack.Item key={index} mx={1}>
            <FamilyNode
              name={node.name}
              gender={node.gender}
              alive={node.alive}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Box>
  );
};

// Main family tree chart component with proper parent-child connections
const FamilyTreeChart = (props: {
  currentHorse: string;
  currentStats: HorseStats;
  tree: FamilyTreeNode;
}) => {
  const { currentHorse, currentStats, tree } = props;
  const [expandedHorse, setExpandedHorse] = useState<string | null>(null);

  const toggleHorse = (horseName: string) => {
    setExpandedHorse(expandedHorse === horseName ? null : horseName);
  };

  return (
    <Box style={{ position: 'relative' }}>
      {/* Current horse */}
      <Box mb={2} textAlign="center">
        <FamilyNode
          name={currentHorse}
          gender="male"
          alive
          current
          onClick={() => toggleHorse(currentHorse)}
          expanded={expandedHorse === currentHorse}
          stats={currentStats}
        />
      </Box>

      {/* Children generation (below current horse) */}
      {tree?.children && tree.children.length > 0 && (
        <>
          {/* Connection lines from parent to children */}
          <Box
            style={{
              position: 'relative',
              height: '30px',
              margin: '0 auto',
              width: '100%',
            }}
          >
            <svg
              style={{
                width: '100%',
                height: '100%',
                position: 'absolute',
                top: 0,
                left: 0,
              }}
            >
              <line
                x1="50%"
                y1="0"
                x2="50%"
                y2="30"
                stroke="#444"
                strokeWidth="2"
              />
            </svg>
          </Box>

          <Box mb={3}>
            <Box
              style={{
                fontSize: '11px',
                color: '#888',
                marginBottom: '4px',
                textAlign: 'center',
              }}
            >
              Children
            </Box>
            <Stack justify="center" wrap>
              {tree.children.map((child, index) => (
                <Stack.Item key={index} mx={1}>
                  <FamilyNode
                    name={child.name}
                    gender={child.gender}
                    alive={child.alive}
                    onClick={() => toggleHorse(child.name)}
                    expanded={expandedHorse === child.name}
                    stats={child.stats}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Box>
        </>
      )}

      {/* Parents generation */}
      {tree &&
        (tree.fatherName !== 'Unknown' || tree.motherName !== 'Unknown') && (
          <>
            {/* Connection lines from child to parents */}
            <Box
              style={{
                position: 'relative',
                height: '30px',
                margin: '0 auto',
                width: '100%',
              }}
            >
              <svg
                style={{
                  width: '100%',
                  height: '100%',
                  position: 'absolute',
                  top: 0,
                  left: 0,
                }}
              >
                {/* Vertical line down from child */}
                {(tree.fatherName !== 'Unknown' ||
                  tree.motherName !== 'Unknown') && (
                  <line
                    x1="50%"
                    y1="0"
                    x2="50%"
                    y2="15"
                    stroke="#444"
                    strokeWidth="2"
                  />
                )}
                {/* Horizontal line connecting to parents */}
                {tree.fatherName !== 'Unknown' &&
                  tree.motherName !== 'Unknown' && (
                    <line
                      x1="25%"
                      y1="15"
                      x2="75%"
                      y2="15"
                      stroke="#444"
                      strokeWidth="2"
                    />
                  )}
                {/* Line down to father */}
                {tree.fatherName !== 'Unknown' && (
                  <line
                    x1="25%"
                    y1="15"
                    x2="25%"
                    y2="30"
                    stroke="#444"
                    strokeWidth="2"
                  />
                )}
                {/* Line down to mother */}
                {tree.motherName !== 'Unknown' && (
                  <line
                    x1="75%"
                    y1="15"
                    x2="75%"
                    y2="30"
                    stroke="#444"
                    strokeWidth="2"
                  />
                )}
              </svg>
            </Box>

            {/* Parents - using absolute positioning grid */}
            <Box
              style={{
                position: 'relative',
                display: 'grid',
                gridTemplateColumns: '1fr 1fr',
                marginBottom: '16px',
              }}
            >
              {tree.fatherName !== 'Unknown' && (
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'center',
                    paddingLeft: '8px',
                    paddingRight: '8px',
                  }}
                >
                  <FamilyNode
                    name={tree.fatherName}
                    gender="male"
                    alive={tree.fatherAlive}
                    onClick={() => toggleHorse(tree.fatherName)}
                    expanded={expandedHorse === tree.fatherName}
                    stats={tree.fatherStats}
                  />
                </Box>
              )}
              {tree.motherName !== 'Unknown' && (
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'center',
                    paddingLeft: '8px',
                    paddingRight: '8px',
                    gridColumn: tree.fatherName === 'Unknown' ? '2' : 'auto',
                  }}
                >
                  <FamilyNode
                    name={tree.motherName}
                    gender="female"
                    alive={tree.motherAlive}
                    onClick={() => toggleHorse(tree.motherName)}
                    expanded={expandedHorse === tree.motherName}
                    stats={tree.motherStats}
                  />
                </Box>
              )}
            </Box>

            {/* Grandparents generation */}
            {(tree.fatherTree || tree.motherTree) && (
              <>
                {/* Connection lines from parents to grandparents */}
                <Box
                  style={{
                    position: 'relative',
                    height: '30px',
                    margin: '0 auto',
                    width: '100%',
                  }}
                >
                  <svg
                    style={{
                      width: '100%',
                      height: '100%',
                      position: 'absolute',
                      top: 0,
                      left: 0,
                    }}
                  >
                    {/* Lines from father (at 25%) to his parents */}
                    {tree.fatherTree && tree.fatherName !== 'Unknown' && (
                      <>
                        {/* Vertical line down from father */}
                        {(tree.fatherTree.fatherName !== 'Unknown' ||
                          tree.fatherTree.motherName !== 'Unknown') && (
                          <line
                            x1="25%"
                            y1="0"
                            x2="25%"
                            y2="15"
                            stroke="#444"
                            strokeWidth="2"
                          />
                        )}
                        {/* Horizontal line between paternal grandparents */}
                        {tree.fatherTree.fatherName !== 'Unknown' &&
                          tree.fatherTree.motherName !== 'Unknown' && (
                            <line
                              x1="12.5%"
                              y1="15"
                              x2="37.5%"
                              y2="15"
                              stroke="#444"
                              strokeWidth="2"
                            />
                          )}
                        {/* Line down to paternal grandfather */}
                        {tree.fatherTree.fatherName !== 'Unknown' && (
                          <line
                            x1="12.5%"
                            y1="15"
                            x2="12.5%"
                            y2="30"
                            stroke="#444"
                            strokeWidth="2"
                          />
                        )}
                        {/* Line down to paternal grandmother */}
                        {tree.fatherTree.motherName !== 'Unknown' && (
                          <line
                            x1="37.5%"
                            y1="15"
                            x2="37.5%"
                            y2="30"
                            stroke="#444"
                            strokeWidth="2"
                          />
                        )}
                      </>
                    )}
                    {/* Lines from mother (at 75%) to her parents */}
                    {tree.motherTree && tree.motherName !== 'Unknown' && (
                      <>
                        {/* Vertical line down from mother */}
                        {(tree.motherTree.fatherName !== 'Unknown' ||
                          tree.motherTree.motherName !== 'Unknown') && (
                          <line
                            x1="75%"
                            y1="0"
                            x2="75%"
                            y2="15"
                            stroke="#444"
                            strokeWidth="2"
                          />
                        )}
                        {/* Horizontal line between maternal grandparents */}
                        {tree.motherTree.fatherName !== 'Unknown' &&
                          tree.motherTree.motherName !== 'Unknown' && (
                            <line
                              x1="62.5%"
                              y1="15"
                              x2="87.5%"
                              y2="15"
                              stroke="#444"
                              strokeWidth="2"
                            />
                          )}
                        {/* Line down to maternal grandfather */}
                        {tree.motherTree.fatherName !== 'Unknown' && (
                          <line
                            x1="62.5%"
                            y1="15"
                            x2="62.5%"
                            y2="30"
                            stroke="#444"
                            strokeWidth="2"
                          />
                        )}
                        {/* Line down to maternal grandmother */}
                        {tree.motherTree.motherName !== 'Unknown' && (
                          <line
                            x1="87.5%"
                            y1="15"
                            x2="87.5%"
                            y2="30"
                            stroke="#444"
                            strokeWidth="2"
                          />
                        )}
                      </>
                    )}
                  </svg>
                </Box>

                {/* Grandparents - using grid layout */}
                <Box
                  style={{
                    display: 'grid',
                    gridTemplateColumns: '1fr 1fr 1fr 1fr',
                    marginBottom: '16px',
                  }}
                >
                  {/* Paternal grandfather (12.5% position) */}
                  {tree.fatherTree?.fatherName !== 'Unknown' &&
                    tree.fatherTree && (
                      <Box
                        style={{
                          display: 'flex',
                          justifyContent: 'center',
                          padding: '4px',
                        }}
                      >
                        <FamilyNode
                          name={tree.fatherTree!.fatherName}
                          gender="male"
                          alive={tree.fatherTree!.fatherAlive}
                          onClick={() =>
                            toggleHorse(tree.fatherTree!.fatherName)
                          }
                          expanded={
                            expandedHorse === tree.fatherTree!.fatherName
                          }
                          stats={tree.fatherTree!.fatherStats}
                        />
                      </Box>
                    )}
                  {/* Paternal grandmother (37.5% position) */}
                  {tree.fatherTree?.motherName !== 'Unknown' &&
                    tree.fatherTree && (
                      <Box
                        style={{
                          display: 'flex',
                          justifyContent: 'center',
                          padding: '4px',
                          gridColumn:
                            tree.fatherTree!.fatherName === 'Unknown'
                              ? '2'
                              : '2',
                        }}
                      >
                        <FamilyNode
                          name={tree.fatherTree!.motherName}
                          gender="female"
                          alive={tree.fatherTree!.motherAlive}
                          onClick={() =>
                            toggleHorse(tree.fatherTree!.motherName)
                          }
                          expanded={
                            expandedHorse === tree.fatherTree!.motherName
                          }
                          stats={tree.fatherTree!.motherStats}
                        />
                      </Box>
                    )}
                  {/* Maternal grandfather (62.5% position) */}
                  {tree.motherTree?.fatherName !== 'Unknown' &&
                    tree.motherTree && (
                      <Box
                        style={{
                          display: 'flex',
                          justifyContent: 'center',
                          padding: '4px',
                          gridColumn: '3',
                        }}
                      >
                        <FamilyNode
                          name={tree.motherTree!.fatherName}
                          gender="male"
                          alive={tree.motherTree!.fatherAlive}
                          onClick={() =>
                            toggleHorse(tree.motherTree!.fatherName)
                          }
                          expanded={
                            expandedHorse === tree.motherTree!.fatherName
                          }
                          stats={tree.motherTree!.fatherStats}
                        />
                      </Box>
                    )}
                  {/* Maternal grandmother (87.5% position) */}
                  {tree.motherTree?.motherName !== 'Unknown' &&
                    tree.motherTree && (
                      <Box
                        style={{
                          display: 'flex',
                          justifyContent: 'center',
                          padding: '4px',
                          gridColumn: '4',
                        }}
                      >
                        <FamilyNode
                          name={tree.motherTree!.motherName}
                          gender="female"
                          alive={tree.motherTree!.motherAlive}
                          onClick={() =>
                            toggleHorse(tree.motherTree!.motherName)
                          }
                          expanded={
                            expandedHorse === tree.motherTree!.motherName
                          }
                          stats={tree.motherTree!.motherStats}
                        />
                      </Box>
                    )}
                </Box>
              </>
            )}
          </>
        )}

      {!tree && (
        <Box color="label" fontSize="12px" textAlign="center" italic mt={2}>
          Parents unknown - first generation
        </Box>
      )}
    </Box>
  );
};

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
  pregnant: boolean;
  canBreed: boolean;
  breed?: BreedInfo;
  owner: string | null;
  isOwner: boolean;
  familyTree: FamilyTreeNode | null;
};

export const HorseMenu = (props) => {
  const { act, data } = useBackend<HorseData>();
  const [selectedTab, setSelectedTab] = useState('stats');

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
    pregnant,
    canBreed,
    breed,
    owner,
    isOwner,
    familyTree,
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
            <Tabs>
              <Tabs.Tab
                selected={selectedTab === 'stats'}
                onClick={() => setSelectedTab('stats')}
              >
                Stats & Breeding
              </Tabs.Tab>
              <Tabs.Tab
                selected={selectedTab === 'family'}
                onClick={() => setSelectedTab('family')}
              >
                Family Tree
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          {selectedTab === 'stats' ? (
            <>
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
                              : Math.abs(temperament - breed.idealTemperament) <
                                  20
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
                            Math.abs(intelligence - breed.idealIntelligence) <
                            10
                              ? 'good'
                              : Math.abs(
                                    intelligence - breed.idealIntelligence,
                                  ) < 20
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
            </>
          ) : (
            <Stack.Item>
              <Section title="Family Dynasty" fill>
                {familyTree ? (
                  <FamilyTreeChart
                    currentHorse={name}
                    currentStats={{
                      temperament,
                      intelligence,
                      speed,
                    }}
                    tree={familyTree}
                  />
                ) : (
                  <Box
                    mt={2}
                    mb={2}
                    color="label"
                    fontSize="14px"
                    italic
                    textAlign="center"
                  >
                    This horse has no recorded lineage.
                  </Box>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
