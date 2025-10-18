import { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Flex, NoticeBox, Section } from 'tgui-core/components';
import { Window } from '../layouts';
import { SupercruiseMapSvg } from '../components/SupercruiseMapSvg';

export const SupercruiseMap = (props) => {
  const { act, data } = useBackend();
  const {
    map_objects = [],
    linkedToShuttle = false,
    shuttleName = '',
    shuttleAngle = 0,
    shuttleThrust = 0,
    shuttleVelX = 0,
    shuttleVelY = 0,
    update_index = 0,
    ourObject = null,
    autopilotEnabled = false,
    targetX = null,
    targetY = null,
    isDocked = false,
    dockedStation = null,
    nearbyStations = [],
    nearbyObjects = [],
  } = data;

  const [zoomScale, setZoomScale] = useState(1);

  // Calculate velocity angle and speed
  const velocitySpeed = Math.sqrt(shuttleVelX * shuttleVelX + shuttleVelY * shuttleVelY);
  const velocityAngle = velocitySpeed > 0.01
    ? (Math.atan2(shuttleVelY, shuttleVelX) * 180 / Math.PI + 360) % 360
    : 0;

  // Auto-center camera on our shuttle
  const xOffset = linkedToShuttle && ourObject ? -ourObject.position_x : 0;
  const yOffset = linkedToShuttle && ourObject ? -ourObject.position_y : 0;

  return (
    <Window width={1000} height={700}>
      <Window.Content>
        <Flex height="100%">
          <Flex.Item grow>
            <Box position="relative" height="100%" backgroundColor="#0a0a1a">
              {/* Map display */}
              <SupercruiseMapSvg
                map_objects={map_objects}
                update_index={update_index}
                xOffset={xOffset}
                yOffset={yOffset}
                zoomScale={zoomScale}
                shuttleAngle={shuttleAngle}
                shuttleThrust={shuttleThrust}
                ourObject={ourObject}
                targetX={targetX}
                targetY={targetY}
                isDocked={isDocked}
                autopilotEnabled={autopilotEnabled}
                onMapClick={(worldX, worldY, altKey) => {
                  // Don't allow map clicks when docked
                  if(!isDocked) {
                    act('setTargetCoords', {
                      x: worldX,
                      y: worldY,
                      altKey: altKey,
                    });
                  }
                }}
              />
            </Box>
          </Flex.Item>

          <Flex.Item width="300px">
            <Section title="Flight Controls" height="100%">
              {/* Zoom controls - moved here to avoid blocking map clicks */}
              <Flex mb={2}>
                <Flex.Item grow>
                  <Box bold>Zoom</Box>
                </Flex.Item>
                <Flex.Item>
                  <Button
                    compact
                    icon="search-plus"
                    tooltip="Zoom In"
                    onClick={() => setZoomScale(zoomScale * 1.5)}
                  />
                  <Button
                    compact
                    icon="search-minus"
                    tooltip="Zoom Out"
                    onClick={() => setZoomScale(zoomScale / 1.5)}
                  />
                </Flex.Item>
              </Flex>

              {!linkedToShuttle ? (
                <NoticeBox>No shuttle linked to console</NoticeBox>
              ) : (
                <>
                  <Box bold mb={1}>
                    {shuttleName}
                  </Box>

                  <Box mb={2}>
                    <Box>Position: {ourObject?.position_x?.toFixed(1)}, {ourObject?.position_y?.toFixed(1)}</Box>
                    <Box>Velocity: {shuttleVelX?.toFixed(2)}, {shuttleVelY?.toFixed(2)} km/s</Box>
                    <Box color="cyan">Speed: {velocitySpeed.toFixed(2)} km/s @ {velocityAngle.toFixed(0)}°</Box>
                  </Box>

                  <Box bold mb={1}>
                    Thrust Angle: {shuttleAngle}°
                  </Box>
                  <Button
                    icon="plus"
                    disabled={isDocked}
                    onClick={() =>
                      act('set_thrust', {
                        angle: (shuttleAngle + 10) % 360,
                        power: shuttleThrust,
                      })
                    }
                  >
                    Rotate +10°
                  </Button>
                  <Button
                    icon="minus"
                    disabled={isDocked}
                    onClick={() =>
                      act('set_thrust', {
                        angle: (shuttleAngle - 10 + 360) % 360,
                        power: shuttleThrust,
                      })
                    }
                  >
                    Rotate -10°
                  </Button>

                  <Box bold mt={2} mb={1}>
                    Thrust Power: {shuttleThrust}%
                  </Box>
                  <Button
                    icon="arrow-up"
                    disabled={isDocked}
                    onClick={() =>
                      act('set_thrust', {
                        angle: shuttleAngle,
                        power: Math.min(shuttleThrust + 10, 100),
                      })
                    }
                  >
                    Increase
                  </Button>
                  <Button
                    icon="arrow-down"
                    disabled={isDocked}
                    onClick={() =>
                      act('set_thrust', {
                        angle: shuttleAngle,
                        power: Math.max(shuttleThrust - 10, 0),
                      })
                    }
                  >
                    Decrease
                  </Button>

                  <Box mt={3}>
                    {isDocked ? (
                      <NoticeBox color="red">
                        Flight controls locked - Undock to fly
                      </NoticeBox>
                    ) : (
                      <NoticeBox color={autopilotEnabled ? "green" : "purple"}>
                        {autopilotEnabled
                          ? `Autopilot ACTIVE - Flying to (${targetX?.toFixed(0)}, ${targetY?.toFixed(0)})`
                          : "Click in map to fly to location. Alt+Click to stop."}
                      </NoticeBox>
                    )}
                  </Box>

                  {/* Docking/Interaction Section */}
                  <Box mt={3}>
                    {isDocked ? (
                      <>
                        <NoticeBox color="teal">
                          Docked at {dockedStation}
                        </NoticeBox>
                        <Button
                          fluid
                          mt={1}
                          icon="anchor"
                          color="red"
                          onClick={() => act('undock')}
                        >
                          Undock
                        </Button>
                      </>
                    ) : nearbyObjects?.length > 0 ? (
                      <>
                        <Box bold mb={1}>
                          Nearby Objects:
                        </Box>
                        {nearbyObjects.map((obj) => (
                          <Box key={obj.id} mb={1}>
                            <Box>
                              {obj.name}
                              <Box
                                as="span"
                                ml={1}
                                fontSize="0.85em"
                                color={
                                  obj.type === 'station' ? 'blue' :
                                  obj.type === 'planet' ? 'green' :
                                  'gray'
                                }
                              >
                                [{obj.type}]
                              </Box>
                            </Box>
                            <Box fontSize="0.9em" color="gray">
                              {obj.distance}km away
                              {obj.occupied && " (Occupied)"}
                            </Box>
                            <Button
                              icon={obj.type === 'station' ? 'anchor' : 'hand-pointer'}
                              disabled={obj.occupied && obj.type === 'station'}
                              onClick={() =>
                                act('dock', { stationId: obj.id })
                              }
                            >
                              {obj.type === 'station' ? 'Request Docking' : 'Interact'}
                            </Button>
                          </Box>
                        ))}
                      </>
                    ) : (
                      <NoticeBox>
                        No interactable objects in range
                      </NoticeBox>
                    )}
                  </Box>
                </>
              )}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
