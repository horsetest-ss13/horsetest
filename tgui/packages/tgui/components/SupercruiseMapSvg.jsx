import { Component } from 'react';

const FPS = 20;

/**
 * Renders orbital objects on an SVG canvas
 * Updates at 20 FPS for smooth interpolation
 */
export class SupercruiseMapSvg extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tickIndex: -1,
      tickTimer: new Date(),
      objects: {},
    };
  }

  componentDidMount() {
    this.tickUpdate = setInterval(() => this.doTick(), 1000 / FPS);
  }

  componentWillUnmount() {
    clearInterval(this.tickUpdate);
  }

  doTick() {
    const { map_objects = [], update_index } = this.props;
    const newObjects = {};

    // Update all objects
    map_objects.forEach((obj) => {
      newObjects[obj.id] = {
        id: obj.id,
        name: obj.name,
        position_x: obj.position_x,
        position_y: obj.position_y,
        velocity_x: obj.velocity_x,
        velocity_y: obj.velocity_y,
        radius: obj.radius,
        render_mode: obj.render_mode,
        created_at: obj.created_at,
        position_history: obj.position_history,
        docking_range: obj.docking_range,
      };
    });

    this.setState({
      tickIndex: update_index,
      tickTimer: new Date(),
      objects: newObjects,
    });
  }

  render() {
    const {
      xOffset = 0,
      yOffset = 0,
      zoomScale = 1,
      shuttleAngle = 0,
      shuttleThrust = 0,
      ourObject = null,
      onMapClick = null,
      targetX = null,
      targetY = null,
      isDocked = false,
      autopilotEnabled = false,
    } = this.props;
    const { tickIndex, tickTimer, objects } = this.state;
    const { update_index } = this.props;

    // Calculate interpolation elapsed time
    let elapsed = 1;
    if (tickIndex === update_index) {
      const now = new Date();
      elapsed = (now - tickTimer) / 1000;
    }

    // Calculate spinning angle for autopilot target (continuous rotation)
    const spinAngle = (Date.now() / 20) % 360;

    return (
      <svg
        viewBox="-250 -250 500 500"
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          cursor: 'crosshair',
        }}
        onClick={(e) => {
          if (onMapClick) {
            // Get click position relative to SVG
            const svg = e.currentTarget;
            const rect = svg.getBoundingClientRect();
            const clickX = ((e.clientX - rect.left) / rect.width) * 500 - 250;
            const clickY = ((e.clientY - rect.top) / rect.height) * 500 - 250;

            // Convert from screen space to world space
            const worldX = clickX / zoomScale - xOffset;
            const worldY = clickY / zoomScale - yOffset;

            onMapClick(worldX, worldY, e.altKey);
          }
        }}
      >
        {/* Grid background and arrow markers */}
        <defs>
          <pattern
            id="grid"
            width={100 * zoomScale}
            height={100 * zoomScale}
            patternUnits="userSpaceOnUse"
          >
            <rect
              width={100 * zoomScale}
              height={100 * zoomScale}
              fill="#1a1a2e"
            />
            <path
              d={`M ${100 * zoomScale} 0 L 0 0 0 ${100 * zoomScale}`}
              fill="none"
              stroke="#2a2a4a"
              strokeWidth="1"
            />
          </pattern>

          {/* Arrow marker for velocity */}
          <marker
            id="arrowVel"
            markerWidth="10"
            markerHeight="10"
            refX="5"
            refY="3"
            orient="auto"
            markerUnits="strokeWidth"
          >
            <path d="M0,0 L0,6 L9,3 z" fill="#00ffff" />
          </marker>

          {/* Arrow marker for thrust */}
          <marker
            id="arrowThrust"
            markerWidth="10"
            markerHeight="10"
            refX="5"
            refY="3"
            orient="auto"
            markerUnits="strokeWidth"
          >
            <path d="M0,0 L0,6 L9,3 z" fill="#ffff00" />
          </marker>
        </defs>
        <rect x="-50%" y="-50%" width="100%" height="100%" fill="url(#grid)" />

        {/* Render all objects */}
        {Object.values(objects).map((obj) => {
          // Interpolate position for smooth movement (stations and planets don't move)
          const x =
            (obj.position_x + (obj.render_mode !== 'station' && obj.render_mode !== 'planet' ? obj.velocity_x * elapsed : 0) + xOffset) * zoomScale;
          const y =
            (obj.position_y + (obj.render_mode !== 'station' && obj.render_mode !== 'planet' ? obj.velocity_y * elapsed : 0) + yOffset) * zoomScale;
          const r = obj.radius * zoomScale;

          // Color based on type
          const color =
            obj.render_mode === 'shuttle' ? '#a4eea4' :
            obj.render_mode === 'station' ? '#4488ff' :
            obj.render_mode === 'planet' ? (obj.planet_color || '#888888') : '#ffaa00';

          // Calculate if this is our shuttle
          const isOurShuttle = ourObject && obj.id === ourObject.id;
          const isStation = obj.render_mode === 'station';
          const isPlanet = obj.render_mode === 'planet';

          return (
            <g key={obj.id}>
              {/* Show position history trail for our shuttle */}
              {isOurShuttle && obj.position_history && obj.position_history.length > 1 && (
                <polyline
                  points={obj.position_history
                    .map((pos) => {
                      const hx = (pos.x + xOffset) * zoomScale;
                      const hy = (pos.y + yOffset) * zoomScale;
                      return `${hx},${hy}`;
                    })
                    .join(' ')}
                  fill="none"
                  stroke="#a4eea4"
                  strokeWidth={1}
                  opacity={0.5}
                />
              )}

              {/* Render station differently */}
              {isStation ? (
                <>
                  <rect
                    x={x - r}
                    y={y - r}
                    width={r * 2}
                    height={r * 2}
                    fill={color}
                    stroke="#88aaff"
                    strokeWidth={2}
                  />
                  <circle
                    cx={x}
                    cy={y}
                    r={obj.docking_range * zoomScale}
                    fill="none"
                    stroke="#88aaff"
                    strokeWidth={1}
                    strokeDasharray="5,5"
                    opacity={0.3}
                  />
                </>
              ) : isPlanet ? (
                /* Render planets as large circles with a glow effect */
                <>
                  <circle
                    cx={x}
                    cy={y}
                    r={r + 2}
                    fill={color}
                    opacity={0.3}
                  />
                  <circle
                    cx={x}
                    cy={y}
                    r={r}
                    fill={color}
                    stroke={color}
                    strokeWidth={1}
                  />
                </>
              ) : (
                // Don't render ship circle if this is our shuttle and we're docked
                !(isDocked) && (
                  <circle cx={x} cy={y} r={r} fill={color} />
                )
              )}

              {/* Show velocity vector (cyan line) */}
              {isOurShuttle && (obj.velocity_x !== 0 || obj.velocity_y !== 0) && (
                <line
                  x1={x}
                  y1={y}
                  x2={x + obj.velocity_x * 5 * zoomScale}
                  y2={y + obj.velocity_y * 5 * zoomScale}
                  stroke="#00ffff"
                  strokeWidth={2}
                  markerEnd="url(#arrowVel)"
                />
              )}

              {/* Show thrust vector (yellow line) */}
              {isOurShuttle && shuttleThrust > 0 && (
                <line
                  x1={x}
                  y1={y}
                  x2={x + Math.cos(shuttleAngle * Math.PI / 180) * 20 * zoomScale}
                  y2={y + Math.sin(shuttleAngle * Math.PI / 180) * 20 * zoomScale}
                  stroke="#ffff00"
                  strokeWidth={2}
                  markerEnd="url(#arrowThrust)"
                />
              )}

              {/* Don't show name if this is our shuttle and we're docked */}
              {!(isDocked && isOurShuttle) && (
                <text
                  x={x + r + 2}
                  y={y + 4}
                  fill={color}
                  fontSize={Math.min(12 * zoomScale, 14)}
                >
                  {obj.name}
                </text>
              )}
            </g>
          );
        })}

        {/* Show target position marker if set and autopilot is enabled */}
        {autopilotEnabled && targetX !== null && targetY !== null && (
          <g transform={`rotate(${spinAngle} ${(targetX + xOffset) * zoomScale} ${(targetY + yOffset) * zoomScale})`}>
            <circle
              cx={(targetX + xOffset) * zoomScale}
              cy={(targetY + yOffset) * zoomScale}
              r={8}
              fill="none"
              stroke="#ff00ff"
              strokeWidth={2}
            />
            <circle
              cx={(targetX + xOffset) * zoomScale}
              cy={(targetY + yOffset) * zoomScale}
              r={12}
              fill="none"
              stroke="#ff00ff"
              strokeWidth={1}
              strokeDasharray="4,4"
            />
          </g>
        )}
      </svg>
    );
  }
}
